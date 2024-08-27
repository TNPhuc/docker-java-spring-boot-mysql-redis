pipeline {
    agent {
        label 'node-1'
    }
    environment {
        DOCKER_TAG="${GIT_BRANCH.tokenize('/').pop()}-${GIT_COMMIT.substring(0,7)}"
        DOCKER_IMAGE="sixriz/app-java-spring-boot"
    }
    stages {
        stage ('Build image docker') {
            when {
                branch 'develop'
            }
            steps {
                sh "docker build -t $DOCKER_IMAGE:$DOCKER_TAG ."
            }
        }
    }
}