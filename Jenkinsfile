pipeline {
    agent {
        label 'node-1'
    }
    stages {
        stage('Build image') {
            steps {
                script {
                    def dockerTag = "${env.GIT_BRANCH.tokenize('/').pop()}-${env.GIT_COMMIT.substring(0,7)}"
                    def dockerImage = "sixriz/app-java-spring-boot"
                    echo "Building Docker image with tag: ${dockerTag}"
                    sh "docker build -t $dockerImage:$dockerTag ."
                }
            }
        }

        stage('Release image') {
            steps {
                script {
                    def dockerTag = "${env.GIT_BRANCH.tokenize('/').pop()}-${env.GIT_COMMIT.substring(0,7)}"
                    def dockerImage = "sixriz/app-java-spring-boot"
                    echo "Releasing Docker image with tag: ${dockerTag}"
                    sh "docker tag $dockerImage:$dockerTag $dockerImage:latest"
                    withDockerRegistry(credentialsId: 'docker-hub', url: 'https://index.docker.io/v1/') {
                        sh "docker push $dockerImage:$dockerTag"
                        sh "docker push $dockerImage:latest"
                    }
                    sh "docker rmi $dockerImage:$dockerTag"
                    sh "docker rmi $dockerImage:latest"
                }
            }
        }

        stage('Deploy to QA server') {
            steps {
                script {
                    def dockerImage = "sixriz/app-java-spring-boot"
                    echo "Deploying Docker image: ${dockerImage}"
                    sh "docker compose down"
                    sh "docker pull $dockerImage:latest"
                    sh "docker compose up -d"
                    sh "docker image prune -f"
                }
            }
        }
    }
    post {
        success {
            echo "SUCCESSFUL"
        }
        failure {
            echo "FAILED"
        }
        always {
            cleanWs()
        }
    }
}