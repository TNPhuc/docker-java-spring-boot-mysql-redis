pipeline {
    agent {
        label 'node-1'
    }
    environment {
        def dockerTag = "${env.GIT_BRANCH.tokenize('/').pop()}-${env.GIT_COMMIT.substring(0,7)}"
        def dockerImage = "sixriz/app-java-spring-boot"
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

        stage('Deploy to QA server') {
            steps {
                when {
                    branch 'develop'
                }
                script {
                    echo "Deploying Docker image: ${dockerImage} to QA server"
                    sh "docker compose down"
                    //sh "docker pull $dockerImage:latest"
                    sh "docker compose up -d"
                    sh "docker image prune -f"
                }
            }
        }

        stage('Release image') {
            steps {
            when {
                branch 'main'
            }
                script {
                    echo "Releasing Docker image with tag: ${dockerTag} to Docker hub"
                    sh "docker build -t $dockerImage:$dockerTag ."
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