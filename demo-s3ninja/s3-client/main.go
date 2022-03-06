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
	"github.com/aws/aws-sdk-go/aws/awserr"
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
	S3NinjaBucketEnvVariableName = "S3NINJA_BUCKET"

	CommandCreateBucket      = "create-bucket"
	CommandUploadFile        = "upload-random-file"
	CommandListBucketContent = "list-files"
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

func createBucket(session *s3.S3, name string) {
	log.Printf("Creating bucket %q...", name)
	_, err := session.CreateBucket(&s3.CreateBucketInput{Bucket: aws.String(name)})
	if err != nil {
		if err, ok := err.(awserr.Error); ok {
			switch err.Code() {
			case s3.ErrCodeBucketAlreadyExists:
				log.Printf("Bucket %q already exist, skipping creation", name)
			default:
				log.Fatalf(err.Error())
			}
		}
	} else {
		log.Printf("Bucket %q created", name)
	}
}

func uploadRandomFile(session *s3.S3, bucketName string) {
	fileName := fmt.Sprintf("%s.txt", randomCharactersSequence(10))
	log.Printf("Uploading random file %q to bucket %q...", fileName, bucketName)
	_, err := session.PutObject(&s3.PutObjectInput{
		Body:   strings.NewReader(randomCharactersSequence(100)),
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
		log.Printf("%+v", objs)
	}
}

func main() {
	args := os.Args[1:]
	if len(args) == 0 {
		log.Fatalf("Usage: go ./main.go <command>")
	}

	bucketName := os.Getenv(S3NinjaBucketEnvVariableName)
	if bucketName == "" {
		log.Fatalf("Missing env variable %q", S3NinjaBucketEnvVariableName)
	}

	s3session := newS3session()
	switch args[0] {
	case CommandCreateBucket:
		createBucket(s3session, bucketName)
	case CommandUploadFile:
		uploadRandomFile(s3session, bucketName)
	case CommandListBucketContent:
		listBucketContent(s3session, bucketName)
	default:
		log.Fatalf("Command %q not found", args[0])
	}
}
