// Licensed to the Apache Software Foundation (ASF) under one
// or more contributor license agreements.  See the NOTICE file
// distributed with this work for additional information
// regarding copyright ownership.  The ASF licenses this file
// to you under the Apache License, Version 2.0 (the
// "License"); you may not use this file except in compliance
// with the License.  You may obtain a copy of the License at
//
//   http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing,
// software distributed under the License is distributed on an
// "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
// KIND, either express or implied.  See the License for the
// specific language governing permissions and limitations
// under the License.
//
package main

import (
	"fmt"
	"github.com/aws/aws-sdk-go/aws"
	"github.com/aws/aws-sdk-go/aws/credentials"
	"github.com/aws/aws-sdk-go/aws/session"
	"github.com/aws/aws-sdk-go/service/s3"
	"log"
	"os"
	"strings"
)

const (
	AwsRegion       = "eu-central-1"
	AwsClientId     = "AKIAIOSFODNN7EXAMPLE"
	AwsClientSecret = "wJalrXUtnFEMI/K7MDENG/bPxRfiCYEXAMPLEKEY" // dummy credentials

	S3NinjaUrlEnvVariableName    = "S3NINJA_URL"
	S3NinjaBucketEnvVariableName = "S3NINJA_BUCKET_LIST"

	CommandUploadFiles        = "upload-random-files"
	CommandListBucketsContent = "list-files"

	dummyIndexHtmlTemplate = `
	<html>
	<h1> This is the index of %s </h1>
	</html>
	`
)

func newS3session() *s3.S3 {
	awsSession := session.Must(session.NewSession(&aws.Config{
		Region: aws.String(AwsRegion),
		Credentials: credentials.NewStaticCredentials(
			AwsClientId,
			AwsClientSecret,
			"",
		),
	}))
	s3endpoint := os.Getenv(S3NinjaUrlEnvVariableName)
	if s3endpoint == "" {
		log.Fatalf("Missing env variable %q", S3NinjaUrlEnvVariableName)
	}
	return s3.New(awsSession, &aws.Config{Endpoint: aws.String(s3endpoint)})
}

func uploadRandomHtmlFile(session *s3.S3, bucketName string) {
	prefix := randomCharactersSequence(10)
	fileName := fmt.Sprintf("%s/index.html", prefix)
	log.Printf("Uploading random file %q to bucket %q...", fileName, bucketName)

	_, err := session.PutObject(&s3.PutObjectInput{
		Body:   strings.NewReader(fmt.Sprintf(dummyIndexHtmlTemplate, prefix)),
		Key:    aws.String(fileName),
		Bucket: aws.String(bucketName),
		ACL:    aws.String(s3.BucketCannedACLPublicRead),
	})
	if err != nil {
		log.Fatalf(err.Error())
	} else {
		log.Printf("File uploaded successfully")
	}
}

func listBucketContent(session *s3.S3, bucketName string) {
	objs, err := session.ListObjectsV2(&s3.ListObjectsV2Input{
		Bucket: aws.String(bucketName),
	})
	if err != nil {
		log.Fatalf(err.Error())
	} else {
		log.Printf("Bucket %q: \n%+v", bucketName, objs)
	}
}

func getBucketList() ([]string, error) {
	bucketsEnvVariable := os.Getenv(S3NinjaBucketEnvVariableName)
	if bucketsEnvVariable == "" {
		return nil, fmt.Errorf("missing env variable %q", S3NinjaBucketEnvVariableName)
	}
	bucketsEnvVariable = strings.Replace(bucketsEnvVariable, "\"", "", -1)
	bucketsEnvVariable = strings.Replace(bucketsEnvVariable, "(", "", -1)
	bucketsEnvVariable = strings.Replace(bucketsEnvVariable, ")", "", -1)
	return strings.Split(bucketsEnvVariable, " "), nil
}

func main() {
	args := os.Args[1:]
	if len(args) == 0 {
		log.Fatalf("Usage: go ./main.go <command>")
	}
	bucketList, err := getBucketList()
	if err != nil {
		log.Fatal(err.Error())
	}

	s3session := newS3session()
	switch args[0] {
	case CommandUploadFiles:
		for _, bucket := range bucketList {
			uploadRandomHtmlFile(s3session, bucket)
		}
	case CommandListBucketsContent:
		for _, bucket := range bucketList {
			listBucketContent(s3session, bucket)
		}
	default:
		log.Fatalf("Command %q not found", args[0])
	}
}
