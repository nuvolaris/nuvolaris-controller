## Kind

>  kubernetes environment based on kind (uses let's encrypt self signed certificate in this case, as staging and production ones requires reachability of the ingress host server via a registered DNS name)

```sh
task setup-cm
task deploy
curl https://securedemo-nuvolaris.eu/echo1
```

To cleanup
```sh
task clean-all
```