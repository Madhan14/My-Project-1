pipeline {
    agent any

    triggers {
        githubPush()   // <-- This makes Jenkins listen for GitHub pushes
    }

    environment {
        DEV_IMAGE = "madhan14/dev:latest"
        PROD_IMAGE = "madhan14/prod:latest"
    }

    stages {
        stage('Checkout') {
            steps {
               git branch: 'dev', url: 'https://github.com/Madhan14/My-Project-1.git', credentialsId: 'Github-Token'

            }
        }

        stage('Docker Login') {
            steps {
                withCredentials([usernamePassword(credentialsId: 'dockerhub-creds',
                                                  usernameVariable: 'DOCKER_USER',
                                                  passwordVariable: 'DOCKER_PASS')]) {
                    sh '''
                        echo "$DOCKER_PASS" | docker login -u "$DOCKER_USER" --password-stdin
                    '''
                }
            }
        }

        stage('Build Docker Image') {
            steps {
                script {
                    sh "docker build -t myapp:${env.BUILD_NUMBER} ."
                }
            }
        }

        stage('Push to DockerHub') {
            steps {
                script {
                    if (env.BRANCH_NAME == "main") {
                        sh """
                            docker tag myapp:${env.BUILD_NUMBER} ${DEV_IMAGE}
                            docker push ${DEV_IMAGE}
                        """
                    } else if (env.BRANCH_NAME == "dev") {
                        sh """
                            docker tag myapp:${env.BUILD_NUMBER} ${PROD_IMAGE}
                            docker push ${PROD_IMAGE}
                        """
                    }
                }
            }
        }

        stage('Deploy to EC2') {
            steps {
                sshagent(['linux-SSH-key']) {
                    script {
                        if (env.BRANCH_NAME == "main") {
                            sh '''
                                ssh -o StrictHostKeyChecking=no ubuntu@<EC2-PUBLIC-IP> "
                                    docker pull ${DEV_IMAGE} &&
                                    docker stop myapp || true &&
                                    docker rm myapp || true &&
                                    docker run -d -p 80:80 --name myapp ${DEV_IMAGE}
                                "
                            '''
                        } else if (env.BRANCH_NAME == "dev") {
                            sh '''
                                ssh -o StrictHostKeyChecking=no ubuntu@<43.205.230.61> "
                                    docker pull ${PROD_IMAGE} &&
                                    docker stop myapp || true &&
                                    docker rm myapp || true &&
                                    docker run -d -p 80:80 --name myapp ${PROD_IMAGE}
                                "
                            '''
                        }
                    }
                }
            }
        }
    }
}
