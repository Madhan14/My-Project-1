pipeline {
    agent any

    triggers {
        githubPush()   // listen for GitHub webhooks
    }

    environment {
        DEV_IMAGE = "madhan14/dev"
        PROD_IMAGE = "madhan14/prod"
    }

    stages {
        stage('Checkout') {
            steps {
                git branch: "${env.BRANCH_NAME}", url: 'https://github.com/Madhan14/My-Project-1.git'
            }
        }

        stage('Docker Login') {
            steps {
                withCredentials([usernamePassword(credentialsId: 'docker-hub-creds',
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
                    COMMIT_HASH = sh(script: "git rev-parse --short HEAD", returnStdout: true).trim()
                    IMAGE_TAG = "${env.BUILD_NUMBER}-${COMMIT_HASH}"
                    sh "docker build -t myapp:${IMAGE_TAG} ."
                }
            }
        }

        stage('Push to DockerHub') {
            steps {
                script {
                    if (env.BRANCH_NAME == "dev") {
                        sh """
                            docker tag myapp:${IMAGE_TAG} ${DEV_IMAGE}:latest
                            docker tag myapp:${IMAGE_TAG} ${DEV_IMAGE}:${IMAGE_TAG}
                            docker push ${DEV_IMAGE}:latest
                            docker push ${DEV_IMAGE}:${IMAGE_TAG}
                        """
                    } else if (env.BRANCH_NAME == "main" || env.BRANCH_NAME == "dev") {
                        sh """
                            docker tag myapp:${IMAGE_TAG} ${PROD_IMAGE}:latest
                            docker tag myapp:${IMAGE_TAG} ${PROD_IMAGE}:${IMAGE_TAG}
                            docker push ${PROD_IMAGE}:latest
                            docker push ${PROD_IMAGE}:${IMAGE_TAG}
                        """
                    }
                }
            }
        }

        stage('Deploy to EC2') {
            steps {
                sshagent(['linux-SSH-key']) {
                    script {
                        if (env.BRANCH_NAME == "dev") {
                            sh """
                                ssh -o StrictHostKeyChecking=no ubuntu@<43.205.230.61> '
                                    docker pull ${DEV_IMAGE}:latest &&
                                    docker stop myapp || true &&
                                    docker rm myapp || true &&
                                    docker run -d -p 80:80 --name myapp ${DEV_IMAGE}:latest
                                '
                            """
                        } else if (env.BRANCH_NAME == "main" || env.BRANCH_NAME == "dev") {
                            sh """
                                ssh -o StrictHostKeyChecking=no ubuntu@<43.205.230.61> '
                                    docker pull ${PROD_IMAGE}:latest &&
                                    docker stop myapp || true &&
                                    docker rm myapp || true &&
                                    docker run -d -p 80:80 --name myapp ${PROD_IMAGE}:latest
                                '
                            """
                        }
                    }
                }
            }
        }
    }
}
