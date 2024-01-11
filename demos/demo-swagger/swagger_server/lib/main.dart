import 'dart:io';
import 'dart:convert';
import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart' as io;
import 'package:shelf_router/shelf_router.dart';
import 'package:shelf_swagger_ui/shelf_swagger_ui.dart';
import 'package:http/http.dart' as http;

HttpServer? activeServer; // Variabile globale per tenere traccia del server
const toServeFilename = 'toserve.json';

void main(List<String> args) async {
  final router = Router();

  // Endpoint per il reload
  router.get('/reloadSwagger', (Request request) async {
    await reloadSwagger();
    return Response.ok('Swagger reload completato');
  });

  // Configura il router per servire la UI di Swagger
  // Aggiungi il handler di Swagger direttamente al router
  router.mount('/swagger/',
      SwaggerUI('openapi/$toServeFilename', title: 'Swagger Test').call);

  // Configura l'handler del server con il router
  final handler =
      const Pipeline().addMiddleware(logRequests()).addHandler(router.call);

  // Avvia il server
  var server = await io.serve(handler, '0.0.0.0', 8080);
  print('Serving at http://${server.address.host}:${server.port}');

  // Esegui il primo caricamento all'avvio
  await reloadSwagger();
}

Future<void> reloadSwagger() async {
  // Chiudi il server precedente, se esiste
  if (activeServer != null) {
    await activeServer!.close();
    activeServer = null;
  }

  // Creazione o pulizia della cartella 'openapi'
  final directory = Directory('openapi');
  if (await directory.exists()) {
    await directory.delete(
        recursive: true); // Cancella la cartella e tutto il suo contenuto
  }
  await directory.create(); // Crea nuovamente la cartella

  // A. Determinare il dominio
  var authorizationkey = Platform.environment['AUTHORIZATION_KEY'] ?? 'your_encoded_credentials';
  var encodedAuthorizationKey = base64.encode(utf8.encode(authorizationkey));
  if (authorizationkey == 'your_encoded_credentials') {
    print('ATTENZIONE: non hai impostato le credenziali di autenticazione per OpenWhisk');
  }
  var runningInContainer = Platform.environment['RUNNING_IN_CONTAINER'] ?? 'LOCAL';
  var apisixAdmin = 'http://localhost:9280';
  var controllername = 'controller';
  switch (runningInContainer) {
    case 'LOCAL':
      print('Running in local mode');
      apisixAdmin = 'http://localhost:9280';
      controllername = 'localhost';
      break;
    case 'DOCKER':
      print('Running in DOCKER mode');
      apisixAdmin = 'http://host.docker.internal:9280';
      controllername = 'host.docker.internal';
      break;
    case 'KUBERNETES':
      print('Running in KUBERNETES mode');
      apisixAdmin = 'http://apisix-admin:9280';
      controllername = 'controller';
      break;
    default:
      print('Running in unknown mode');
  }

  // B. Eseguire una GET verso l'API di APISIX
  final response = await http.get(
    Uri.parse('$apisixAdmin/apisix/admin/routes/'),
    headers: {'x-api-key': 'edd1c9f034335f136f87ad84b625c8f1'},
  );

// C. Elaborare la risposta per estrarre le azioni OpenWhisk
  final data = json.decode(response.body);
  final openwhiskActions = <String>[];

  for (var item in data['list']) {
    final plugins = item['value']?['plugins'];
    final openwhisk = plugins?['openwhisk'];

    if (openwhisk != null) {
      final package = openwhisk['package'];
      final action = openwhisk['action'];

      if (package != null && action != null) {
        openwhiskActions.add('/nuvolaris/actions/$package/$action');
      }
    }
  }

  // D. Eseguire una GET verso l'API di OpenWhisk
  final openapiJsons = <String, String>{};
  bool isOpenApiValid(dynamic Json) {
    // Accede al campo 'body' dell'oggetto JSON
    var xjson = Json['response']['result']['body'];
    return xjson != null && xjson['openapi'] == '3.0.0';
  }
/*
  for (var action in openwhiskActions) {
    final result = await Process.run('nuv', [
      'action',
      'invoke',
      action,
      '--param',
      'method',
      'POST',
      '--param',
      'generateopenapi',
      'TRUE',
      '-r'
    ]);

    if (result.exitCode == 0) {
      try {
        final openapiJson = json.decode(result.stdout);
        // Verifica che il JSON sia conforme allo standard OpenAPI 3.0.0
        print(result.stdout);
        if (isOpenApiValid(openapiJson)) {
          Map<String, dynamic> xjson = json.decode(result.stdout)['body'];
          openapiJsons[action] = json.encode(xjson);
        }
      } catch (e) {
        // La stringa di output non è un JSON valido
        print(e);
      }
    }
*/
for (var action in openwhiskActions) {
  var url = Uri.parse('http://$controllername:3233/api/v1/namespaces$action?response=true&blocking=true&timeout=30000');
  var response = await http.post(
    url,
    headers: {
      'Content-Type': 'application/json',
      'Authorization': 'Basic $encodedAuthorizationKey' // Aggiungi qui le tue credenziali
    },
    body: json.encode({
      'method': 'POST',
      'generateopenapi': 'TRUE'
    })
  );

  if (response.statusCode == 200) {
    try {
      final openapiJson = json.decode(response.body);
      // Il resto della logica...
              print(openapiJson);
        if (isOpenApiValid(openapiJson)) {
          //Map<String, dynamic> xjson = json.decode(openapiJson)['response']['result']['body'];
          // Accede al campo 'body' dell'oggetto JSON
          var xjson = openapiJson['response']['result']['body'];
          openapiJsons[action] = json.encode(xjson);
          print('jsonbody found');
        }
    } catch (e) {
      print(e);
    }
  }else{
    String resp = response.statusCode.toString() + ' headers: ' + response.request!.headers.toString() + ' body: ' + response.body.toString() + ' reason: ' + response.reasonPhrase.toString() + ' response: ' + response.toString() ;
    print ('response url:$url openwhisk in error $resp');
  }


  }

// Passaggio per cancellare i file esistenti nella directory 'openapi'
  if (await directory.exists()) {
    await for (var file in directory.list()) {
      if (file is File) {
        await file.delete();
        print('Cancellato il file ${file.uri.pathSegments.last}');
      }
    }
  }

  // E. Scrivi i file JSON in directory
  for (var entry in openapiJsons.entries) {
    final filename = entry.key.replaceAll('/', '_') + '.json';
    final file = File('openapi/$filename');
    await file.writeAsString(entry.value);
    print('Scritto il file $filename');
  }

// F. Aggrega i file JSON in un unico file

  final aggregatedSwagger = <String, dynamic>{
    'openapi': '3.0.0',
    'info': <String, dynamic>{
      'title': 'API Aggregata',
      'version': '1.0.0',
    },
    'paths': <String, dynamic>{},
    'components': <String, dynamic>{
      'schemas': <String, dynamic>{},
      'securitySchemes': <String, dynamic>{},
    },
    'servers': <dynamic>[],
    'tags': <dynamic>[],
  };

  await for (var entity in directory.list()) {
    if (entity is File &&
        entity.path.endsWith('.json') &&
        !entity.path.endsWith(toServeFilename)) {
      var content =
          json.decode(await entity.readAsString()) as Map<String, dynamic>;
      var filename = entity.uri.pathSegments.last;
      var tag = filename.replaceAll('.json', '');

      aggregatedSwagger['tags'].add({
        'name': tag,
        'description': 'API definita in $filename',
      });

      _mergeSwaggerComponents(aggregatedSwagger, content, tag);
      _mergeServers(aggregatedSwagger, content);
    }
  }

  File('openapi/$toServeFilename')
      .writeAsStringSync(json.encode(aggregatedSwagger));

  //final handler = SwaggerUI('openapi/$toServeFilename', title: 'Swagger Test');
  //activeServer = await io.serve(handler, '0.0.0.0', 8080);
  //print('Serving at http://${activeServer?.address.host}:${activeServer?.port}');
  print('json ready');
}

void _mergeSwaggerComponents(
    Map<String, dynamic> aggregated, Map<String, dynamic> content, String tag) {
  var paths = content['paths'] as Map<String, dynamic>?;
  var components = content['components'] as Map<String, dynamic>?;

  if (components != null) {
    _mergeComponents(aggregated['components'], components, tag);
  }

  if (paths != null) {
    _mergePaths(aggregated['paths'], paths, tag, aggregated['components']);
  }
}

void _mergePaths(Map<String, dynamic> target, Map<String, dynamic> source,
    String tag, Map<String, dynamic> globalComponents) {
  source.forEach((pathKey, pathValue) {
    target[pathKey] = pathValue;
    _updateReferencesInPath(pathValue, tag, globalComponents);
  });
}

void _updateReferencesInPath(Map<String, dynamic> path, String tag,
    Map<String, dynamic> globalComponents) {
  path.forEach((methodKey, methodValue) {
    if (methodValue is Map<String, dynamic>) {
      if (methodValue.containsKey('tags')) {
        methodValue['tags'] = [tag];
      }
      _updateReferences(methodValue, tag, globalComponents);
    }
  });
}

void _mergeComponents(
    Map<String, dynamic> target, Map<String, dynamic> source, String tag) {
  var schemas = source['schemas'] as Map<String, dynamic>?;
  var securitySchemes = source['securitySchemes'] as Map<String, dynamic>?;

  if (schemas != null) {
    schemas.forEach((schemaKey, schemaValue) {
      var newKey = '$tag' + '_$schemaKey';
      target['schemas'][newKey] = schemaValue;
    });
  }

  if (securitySchemes != null) {
    securitySchemes.forEach((schemeKey, schemeValue) {
      // Aggiungi un prefisso ai securitySchemes per evitare conflitti
      var newKey = '$tag' + '_$schemeKey';
      // Se il securityScheme è già definito, non sovrascriverlo
      if (!target['securitySchemes'].containsKey(newKey)) {
        target['securitySchemes'][newKey] = schemeValue;
      }
    });
  }
}

void _mergeServers(
    Map<String, dynamic> aggregated, Map<String, dynamic> content) {
  var servers = content['servers'] as List<dynamic>?;
  if (servers != null) {
    for (var server in servers) {
      if (!aggregated['servers'].contains(server)) {
        aggregated['servers'].add(server);
      }
    }
  }
}

void _updateReferences(
    dynamic value, String tag, Map<String, dynamic> globalComponents) {
  if (value is Map<String, dynamic>) {
    value.forEach((key, subValue) {
      // Aggiorna i riferimenti `$ref`
      if (key == '\$ref' && subValue is String) {
        var refParts = subValue.split('/');
        if (refParts.length == 4 && refParts[2] == 'schemas') {
          var schemaName = refParts[3];
          // Controlla se lo schema esiste nei componenti globali
          if (globalComponents.containsKey(schemaName)) {
            // Usa il riferimento globale se esiste
            value[key] = '#/components/schemas/$schemaName';
          } else {
            // Altrimenti, usa il riferimento locale con il prefisso
            value[key] = '#/components/schemas/$tag' + '_$schemaName';
          }
        }
      } else {
        // Ricorsione per esplorare strutture annidate
        _updateReferences(subValue, tag, globalComponents);
      }
    });
  } else if (value is List) {
    for (var item in value) {
      _updateReferences(item, tag, globalComponents);
    }
  }
}
