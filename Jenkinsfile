pipeline {
    agent any

    environment {
        IMAGE = 'a6h15hek/production-1:latest'
        KUBECONFIG = '/var/lib/jenkins/jenkins-kubeconfig'
    }

    stages {

        stage('Git Checkout') {
            steps {
                git branch: 'main',
                    url: 'https://github.com/abhibc0202/production-1.git'
            }
        }

        stage('Build Docker Image') {
            steps {
                sh '''
                    set -eu
                    cd app
                    docker build --pull -t $IMAGE .
                '''
            }
        }

        stage('Push Docker Image') {
            steps {
                withCredentials([usernamePassword(
                    credentialsId: 'dockerhub-creds',
                    usernameVariable: 'DOCKERHUB_USER',
                    passwordVariable: 'DOCKERHUB_TOKEN'
                )]) {
                    sh '''
                        set -eu
                        echo "$DOCKERHUB_TOKEN" | docker login -u "$DOCKERHUB_USER" --password-stdin
                        docker push $IMAGE
                        docker logout
                    '''
                }
            }
        }

        stage('Deploy with Helm') {
            steps {
                sh """
                    set -eu

                    helm upgrade --install production-1 ./helm/production-1 \
                        --namespace production-1 \
                        --take-ownership \
                        --set image.tag=latest \
                        --wait \
                        --timeout 180s

                    kubectl -n production-1 rollout status deployment/production-1 --timeout=180s
                """
            }
        }

        stage('Verify Deployment') {
            steps {
                sh '''
                    set -eu

                    kubectl get deployment production-1 -n production-1
                    kubectl get pods -n production-1 -o wide
                    kubectl get svc -n production-1
                    kubectl get hpa -n production-1
                    kubectl get ingress -n production-1
                '''
            }
        }
    }
}
