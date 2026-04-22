pipeline {
    agent any

    tools {
        maven 'maven-3'
        jdk 'jdk-11'
    }

    environment {
        SONARQUBE_ENV = 'sonarqube-server'
        DOCKER_IMAGE  = 'rajeevgangaraju/poc-1:1.0'
    }

    stages {

        stage('Checkout Code') {
            steps {
                git branch: 'main',
                    url: 'https://github.com/rajeevgangaraju/poc-01.git'
            }
        }

        stage('Compile') {
            steps {
                sh 'mvn clean compile'
            }
        }

        stage('Unit Tests') {
            steps {
                sh 'mvn test'
            }
        }

        stage('SonarQube Analysis') {
            steps {
                withSonarQubeEnv("${SONARQUBE_ENV}") {
                    sh 'mvn sonar:sonar'
                }
            }
        }

        stage('Dependency Check') {
            steps {
                sh 'mvn dependency-check:check -Dnvd.skip=true'
            }
        }

        stage('Build Docker Image') {
            steps {
                sh 'docker build -t $DOCKER_IMAGE .'
            }
        }

        stage('Push Docker Image') {
            steps {
                withDockerRegistry([credentialsId: 'dockerhub-creds', url: '']) {
                    sh 'docker push $DOCKER_IMAGE'
                }
            }
        }

        stage('Trivy Image Scan') {
            steps {
                sh '''
                  trivy image --exit-code 0 --severity LOW,MEDIUM $DOCKER_IMAGE
                  trivy image --exit-code 1 --severity HIGH,CRITICAL $DOCKER_IMAGE
                '''
            }
        }

        stage('Deploy Container') {
            steps {
                sh '''
                  docker rm -f devsecops-poc || true
                  docker run -d \
                  --name devsecops-poc \
                  -p 8080:8080 \
                  $DOCKER_IMAGE
                '''
            }
        }
    }

    post {
        success {
            echo '✅ Pipeline completed successfully'
        }
        failure {
            echo '❌ Pipeline failed'
        }
        always {
            echo 'Pipeline execution finished'
        }
    }
}
