pipeline {
    agent {
        label 'node-1'
    }
    environment {
        DOCKER_TAG="${GIT_BRANCH.tokenize('/').pop()}-${GIT_COMMIT.substring(0,7)}"
        DOCKER_IMAGE="sixriz/app-java-spring-boot"
    }
    stages {
        stage ('Build image') {

            steps {
                sh "docker build -t $DOCKER_IMAGE:$DOCKER_TAG ."
            }
        }

        stage ('Release image') {

            steps {
                sh "docker tag $DOCKER_IMAGE:$DOCKER_TAG $DOCKER_IMAGE:latest"
                withDockerRegistry(credentialsId: 'docker-hub', url: 'https://index.docker.io/v1/'){
                    sh "docker push $DOCKER_IMAGE:$DOCKER_TAG"
                    sh "docker push $DOCKER_IMAGE:latest"
                }
                sh "docker rmi $DOCKER_IMAGE:$DOCKER_TAG"
                sh "docker rmi $DOCKER_IMAGE:latest"
            }
        }

        stage ('Deploy QA server') {

            steps {
                sh "docker compose down"
                sh "docker pull $DOCKER_IMAGE:latest"
                sh "docker compose up -d"
                sh "docker image prune -f"
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