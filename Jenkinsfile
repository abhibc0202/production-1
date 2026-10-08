pipeline {
    agent any

    environment {
        IMAGE = 'a6h15hek/production-1:latest'
        KUBECONFIG = '/var/lib/jenkins/jenkins-kubeconfig'
    }

    stages {

        stage('Build Docker Image') {
            steps {
                sh '''
                    cd app
                    docker build -t $IMAGE .
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
                        echo "$DOCKERHUB_TOKEN" | docker login -u "$DOCKERHUB_USER" --password-stdin
                        docker push $IMAGE
                        docker logout
                    '''
                }
            }
        }

        stage('Deploy to Kubernetes') {
            steps {
                sh '''
                    kubectl apply -f configmap.yaml
                    kubectl apply -f secret.yaml
                    kubectl apply -f pv.yaml
                    kubectl apply -f pvc.yaml
                    kubectl apply -f deployment.yaml
                    kubectl apply -f service.yaml
                    kubectl apply -f hpa.yaml
                    kubectl apply -f ingress.yaml

                    kubectl -n production-1 set image deployment/production-1 nginx=$IMAGE

                    kubectl -n production-1 rollout status deployment/production-1 --timeout=120s
                '''
            }
        }

        stage('Verify Deployment') {
            steps {
                sh '''
                    kubectl get pods -n production-1
                    kubectl get svc -n production-1
                    kubectl get hpa -n production-1
                    kubectl get ingress -n production-1
                '''
            }
        }
    }
}
