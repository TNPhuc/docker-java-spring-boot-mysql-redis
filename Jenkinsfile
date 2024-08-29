pipeline {
    agent none
    stages {
        stage('Build image') {
            agent {
                label 'node-1'
            }
            when {
                branch 'develop'
            }
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
            agent {
                label 'node-1'
            }
            when {
                branch 'develop'
            }
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
            agent {
                label 'node-1'
            }
            when {
                branch 'develop'
            }
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

        stage('Deploy to Production') {
            agent {
                docker {
                    image 'khaliddinh/ansible'
                    args '-v /tmp:/tmp' // Mount thư mục /tmp để lưu SSH key tạm thời
                }
            }
            when {
                branch 'main'
            }
            steps {
                withCredentials([file(credentialsId: 'private-key-deploy-.26', variable: 'ANSIBLE_PRIVATE_KEY')]) {
                    script {
                        // Copy SSH key vào /tmp
                        sh 'cp $ANSIBLE_PRIVATE_KEY /tmp/ansible_key'
                        sh 'chmod 400 /tmp/ansible_key'

                        // Chạy playbook để deploy lên Server B
                        sh 'ansible-playbook -i /ansible/inventory.ini --private-key=/tmp/ansible_key /ansible/playbook.yml'

                        // Xóa SSH key sau khi sử dụng
                        sh 'rm -f /tmp/ansible_key'
                    }
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