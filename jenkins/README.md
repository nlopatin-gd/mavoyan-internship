# Documentation

## Task

![screenshot](../screenshots/jenkins-task/task.png)

### Steps

Download jenkins.war file 

```
wget https://updates.jenkins.io/latest/jenkins.war
```

Start Jenkins
```
java -jar jenkins.war
```
Cat and copy the admin password for jenkins(or find with logs)
```
cat /var/jenkins_home/secrets/initialAdminPassword
```
Open Jenkins on ``localhost:8080``



Ensure the ``GitHub Branch Source Plugin`` is installed.<br/>
![screenshot](../screenshots/jenkins-task/plugin.png)
If it's not installed, add it from the available plugin list.

Fork the following repository and clone it.
https://github.com/avmang/spring-petclinic.git
```
git clone git@github.com:<your_username>/spring-petclinic.git
```
If you don't already have it, add a Dockerfile with the following content:
```
FROM eclipse-temurin:17-jdk AS build

WORKDIR /build

RUN apt-get update && apt-get install -y maven

COPY pom.xml .
COPY src ./src

RUN mvn clean install -DskipTests

FROM eclipse-temurin:17-jdk AS runtime

WORKDIR /build

COPY --from=build /build/target/spring-petclinic-*.jar app.jar

EXPOSE 8080

CMD ["java", "-jar", "app.jar"]
```
For Nexus<br/>
Run Nexus (If you want to use Docker Hub find configurations below)

```
./nexus run
```
Login to Nexus, go to ``Repository->Repositories`` and add 2 hosted docker repositories: ``main`` and ``mr``

![screenshot](../screenshots/jenkins-task/mr.png)
![screenshot](../screenshots/jenkins-task/main.png)

For Docker Hub<br/>
Sign in to Docker Hub and create 2 repositories
``Repository`` -> ``Create Repository``<br/>
Give the same names: main and mr
![screenshot](../screenshots/jenkins-task/dh_repos.png)
In Jenkins: <br/> 
Click on ``New Item``<br/>
Name the project ``petclinic``<br/>
Choose Multibranch Pipeline
Choose git as source<br/>
In Project Repository field fill your repository link: https://github.com/<your_username>/spring-petclinic.git <br/>
Set interval to 1 day(or whatever you want)
![screenshot](../screenshots/jenkins-task/interval.png)

Add a Jenkinsfile with the following content: (For Nexus, you can see Docker Hub version below)

```
pipeline {
    agent any

    environment {
        REPO_MR = "mr"
        REPO_MAIN = "main"
        IMAGE_NAME = "spring-petclinic"
    }

    stages {
        stage ('Checkout') {
            when {
                expression {
                    return env.BRANCH_NAME?.startsWith('other-')
                }
            }
            steps {
                checkout scm
            }
        }

        stage ('Checkstyle') {
            when {
                expression {
                    return env.BRANCH_NAME?.startsWith('other-')
                }
            }
            steps {
                script {
                    sh 'mvn checkstyle:checkstyle'
                }
            }
            post {
                always {
                    archiveArtifacts artifacts: '**/checkstyle-result.xml'
                }
            }
        }

        stage ('Test') {
            when {
                expression {
                    return env.BRANCH_NAME?.startsWith('other-')
                }
            }
            steps {
                script {
                    sh 'mvn test'
                }
            }
        }

        stage ('Build') {
            when {
                expression {
                    return env.BRANCH_NAME?.startsWith('other-')
                }
            }
            steps {
                script {
                    sh 'mvn clean install -DskipTests'
                }
            }
        }

        stage ('Docker Image for MR') {
            when {
                expression {
                    return env.BRANCH_NAME?.startsWith('other-')
                }
            }
            steps {
                script {
                    def shortCommit = env.GIT_COMMIT.substring(0, 7)
                    withCredentials([usernamePassword(
                        credentialsId: 'docker-credentials',
                        usernameVariable: 'DOCKER_CREDS_USR',
                        passwordVariable: 'DOCKER_CREDS_PSW'
                    )]) {
                        sh """
                        echo "${DOCKER_CREDS_PSW}" | docker login localhost:8084 -u "${DOCKER_CREDS_USR}" --password-stdin
                        docker build -t ${IMAGE_NAME}:${shortCommit} .
                        docker tag ${IMAGE_NAME}:${shortCommit} localhost:8084/repository/${REPO_MR}/${IMAGE_NAME}:${shortCommit}
                        docker push localhost:8084/repository/${REPO_MR}/${IMAGE_NAME}:${shortCommit}
                        """
                    }
                }
            }
        }

        stage ('Docker Image for main branch') {
            when {
                expression {
                    env.BRANCH_NAME == 'origin/main' || env.GIT_BRANCH?.contains('main')
                }
            }
            steps {
                script {
                    def shortCommit = env.GIT_COMMIT.substring(0, 7)
                    withCredentials([usernamePassword(
                        credentialsId: 'docker-credentials',
                        usernameVariable: 'DOCKER_CREDS_USR',
                        passwordVariable: 'DOCKER_CREDS_PSW'
                    )]) {
                        sh """
                        echo "${DOCKER_CREDS_PSW}" | docker login localhost:8085 -u "${DOCKER_CREDS_USR}" --password-stdin
                        docker build -t ${IMAGE_NAME}:${shortCommit} .
                        docker tag ${IMAGE_NAME}:${shortCommit} localhost:8085/repository/${REPO_MAIN}/${IMAGE_NAME}:${shortCommit}
                        docker push localhost:8085/repository/${REPO_MAIN}/${IMAGE_NAME}:${shortCommit}
                        """
                    }
                }
            }
        }
    }
}
```
In Jenkins add credentials with this steps <br/>
Manage Jenkins -> Credentials -> System -> Global credentials (unrestricted) -> Add credentials <br/>
Kind -> Username with password <br/>
Add your Docker Hub(Nexus) username and password, click treat username as secret.<br/>
(If you are using Docker Hub generate token and past that as a password)<br/>
Write ``docker-credentials`` as ID
![screenshot](../screenshots/jenkins-task/credentials.png)
<br/>

Jenkinsfile for Docker Hub
```
pipeline {
    agent any

    environment {
        REPO_MAIN = "main"
        REPO_MR = "mr"
        IMAGE_NAME = "spring-petclinic"
    }

    stages {
        stage('Checkout') {
            when {
                expression {
                    return env.BRANCH_NAME?.startsWith('other-')
                }
            }
            steps {
                checkout scm
            }
        }

        stage('Checkstyle') {
            when {
                expression {
                    return env.BRANCH_NAME?.startsWith('other-')
                }
            }
            steps {
                script {
                    sh 'mvn checkstyle:checkstyle'
                }
            }
            post {
                always {
                    archiveArtifacts artifacts: '**/checkstyle-result.xml'
                }
            }
        }

        stage('Test') {
            when {
                expression {
                    return env.BRANCH_NAME?.startsWith('other-')
                }
            }
            steps {
                script {
                    sh 'mvn test'
                }
            }
        }

        stage('Build') {
            when {
                expression {
                    return env.BRANCH_NAME?.startsWith('other-')
                }
            }
            steps {
                script {
                    sh 'mvn clean install -DskipTests'
                }
            }
        }

        stage('Docker Image for MR') {
            when {
                expression {
                    return env.BRANCH_NAME?.startsWith('other-')
                }
            }
            steps {
                script {
                    def shortCommit = env.GIT_COMMIT.substring(0, 7)
                    withCredentials([usernamePassword(
                        credentialsId: 'docker-credentials',
                        usernameVariable: 'DOCKER_HUB_USR',
                        passwordVariable: 'DOCKER_HUB_TOKEN'
                    )]) {
                        sh """
                        echo "${DOCKER_HUB_TOKEN}" | docker login -u "${DOCKER_HUB_USR}" --password-stdin
                        docker build -t ${IMAGE_NAME}:${shortCommit} .
                        docker tag ${IMAGE_NAME}:${shortCommit} ${DOCKER_HUB_USR}/${REPO_MR}:${shortCommit}
                        docker push ${DOCKER_HUB_USR}/${REPO_MR}:${shortCommit}
                        """
                    }
                }
            }
        }

        stage('Docker Image for main branch') {
            when {
                expression {
                    return env.BRANCH_NAME == 'main' || env.BRANCH_NAME?.contains('main')
                }
            }
            steps {
                script {
                    def shortCommit = env.GIT_COMMIT.substring(0, 7)
                    withCredentials([usernamePassword(
                        credentialsId: 'docker-credentials',
                        usernameVariable: 'DOCKER_HUB_USR',
                        passwordVariable: 'DOCKER_HUB_TOKEN'
                    )]) {
                        sh """
                        echo "${DOCKER_HUB_TOKEN}" | docker login -u "${DOCKER_HUB_USR}" --password-stdin
                        docker build -t ${IMAGE_NAME}:${shortCommit} .
                        docker tag ${IMAGE_NAME}:${shortCommit} ${DOCKER_HUB_USR}/${REPO_MAIN}:${shortCommit}
                        docker push ${DOCKER_HUB_USR}/${REPO_MAIN}:${shortCommit}
                        """
                    }
                }
            }
        }
    }
}

```
Commit and push
```
git add <filenames>
git commit -m "added Jenkinsfile"
git push 
```

Go to Jenkins, choose ``petclinic`` and click on ``Scan Multibranch Pipeline Now``

Wait until the process completes successfully.<br/>
Results: (for Docker Hub)
![screenshot](../screenshots/jenkins-task/res1.png)
![screenshot](../screenshots/jenkins-task/res2.png)

To test other stages lets create new branch and do some commit
```
git checkout -b other-branch1
touch a.txt
git add a.txt 
git commit -m "test commit"
git push --set-upstream origin other-branch1
```
And again<br/>

Go to Jenkins, choose ``petclinic`` and click on ``Scan Multibranch Pipeline Now``

Results:
![screenshot](../screenshots/jenkins-task/r1.png)
![screenshot](../screenshots/jenkins-task/r2.png)
![screenshot](../screenshots/jenkins-task/r3.png)
![screenshot](../screenshots/jenkins-task/r4.png)
Results: (for Nexus)
![screenshot](../screenshots/jenkins-task/n1.jpg)
![screenshot](../screenshots/jenkins-task/n2.jpg)
![screenshot](../screenshots/jenkins-task/n3.jpg)