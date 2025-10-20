@Library('Shared')_
pipeline {
    agent any

    stages {
        stage("Code") {
            steps {
                script{
                    clone("https://github.com/Rayees1907/django-notes-application.git","main")
                }
            }
        }

        stage("Build") {
            steps {
                script{
                    build("notes-app", "latest")
                }
            }
        }

        stage("Push") {
            steps {
                script{
                    push("dockerHub", "notes-app", "latest")
                }
            }
        }

        stage("Deploy") {
            steps {
                echo "Deploying using Docker Compose"
                sh "docker compose down && docker compose up -d"
            }
        }
    }
}

