pipeline {
    agent {
        label 'node-1'
    }
    environment {
        dockerTag = "${env.GIT_BRANCH.tokenize('/').pop()}-${env.GIT_COMMIT.substring(0,7)}"
        dockerImage = "sixriz/app-java-spring-boot"
        dockerImageOfficial = "sixriz/app-java-spring-boot-release"
    }
    stages {
        stage('Build image') {
            when {
                branch 'develop'
            }
            steps {
                script {
                    echo "Building Docker image with tag: ${dockerTag}"
                    sh "docker build -t $dockerImage:$dockerTag ."
                }
            }
        }

        stage('Release image branch develop QA') {
            when {
                branch 'develop'
            }
            steps {
                script {
                    echo "Releasing Docker image with tag: ${dockerTag} to Docker hub"
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
            when {
                branch 'develop'
            }
            steps {
                script {
                    echo "Deploying Docker image: ${dockerImage} to QA server"
                    sh "docker compose down"
                    sh "docker pull $dockerImage:latest"
                    sh "docker compose up -d"
                    sh "docker image prune -f"
                }
            }
        }

        stage('Release image official') {
            when {
                branch 'main'
            }
            steps {
                script {
                    echo "Releasing Docker image with tag: ${dockerTag} to Docker hub"
                    sh "docker build -t $dockerImageOfficial:$dockerTag ."
                    sh "docker tag $dockerImageOfficial:$dockerTag $dockerImageOfficial:latest"
                    withDockerRegistry(credentialsId: 'docker-hub', url: 'https://index.docker.io/v1/') {
                        sh "docker push $dockerImageOfficial:$dockerTag"
                        sh "docker push $dockerImageOfficial:latest"
                    }
                    sh "docker rmi $dockerImageOfficial:$dockerTag"
                    sh "docker rmi $dockerImageOfficial:latest"
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
    }
}
