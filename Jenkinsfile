pipeline {
    agent any

    environment {
        DOCKERHUB_USER = "madhan14"
        IMAGE_NAME     = "prod"
        IMAGE          = "${DOCKERHUB_USER}/${IMAGE_NAME}:${BUILD_NUMBER}"
        LATEST         = "${DOCKERHUB_USER}/${IMAGE_NAME}:latest"
        EC2_HOST       = "65.0.4.72"   // Replace with your EC2 Public IP
        EC2_USER       = "ubuntu"
    }

    stages {
        stage('Checkout') {
            steps {
                git branch: "${env.BRANCH_NAME}", url: 'https://github.com/Madhan14/My-Project-1.git'
                sh "echo Branch: ${env.BRANCH_NAME}"
            }
        }

        stage('Build & Push Image') {
            steps {
                script {
                    withCredentials([usernamePassword(credentialsId: 'dockerhub-creds',
                                                     usernameVariable: 'DOCKER_USER',
                                                     passwordVariable: 'DOCKER_PASS')]) {
                        sh """
                            sudo docker build -t ${IMAGE} -t ${LATEST} .
                            echo ${DOCKER_PASS} | sudo docker login -u ${DOCKER_USER} --password-stdin
                            sudo docker push ${IMAGE}
                            sudo docker push ${LATEST}
                        """
                    }
                }
            }
        }

        stage('Deploy to EC2') {
            steps {
                script {
                    echo "Deploying on ${EC2_HOST}"
                    sh """
                        ssh -o StrictHostKeyChecking=no ${EC2_USER}@${EC2_HOST} '
                          sudo docker pull ${LATEST} &&
                          sudo docker stop myapp || true &&
                          sudo docker rm myapp || true &&
                          sudo docker run -d -p 80:80 --name myapp ${LATEST}
                        '
                    """
                }
            }
        }
    }

    post {
        always {
            sh "sudo docker image prune -f || true"
        }
    }
}
