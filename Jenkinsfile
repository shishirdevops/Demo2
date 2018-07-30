node{
 def server = Artifactory.newServer url: 'http://18.210.31.209:8081/artifactory', username: 'admin', password: 'admin'
      def rtMaven = Artifactory.newMavenBuild()
      def mvnHome = tool 'maven-3'
      def buildInfo = Artifactory.newBuildInfo()
	  
	
   stage('SCM Checkout'){
       git credentialsId: 'git-brahma', url: 'https://github.com/reddysbrahma/my-app.git'
   }
   stage ('Artifactory configuration'){
        rtMaven.tool = 'maven-3' 
        rtMaven.deployer releaseRepo:'libs-release-local', snapshotRepo:'libs-release-local' , server: server
        rtMaven.resolver releaseRepo:'libs-release', snapshotRepo:'libs-snapshot' , server: server
      }

    stage ('Exec Maven'){
        rtMaven.run pom: 'pom.xml', goals: 'clean install' , buildInfo: buildInfo
     }
    stage ('Publish build info'){
        server.publishBuildInfo buildInfo
    }
    stage ('get the artifact version'){
    sh " sh gettheversion.sh > commandResult"
   artifact = readFile('commandResult').trim()
    }
   stage('Build Docker Image'){
     sh "docker build -t reddysbrahma/my-app:${artifact} ."
   }
   stage('Push Docker Image'){
     withCredentials([string(credentialsId: 'docker-pwd', variable: 'dockerHubPwd')]) {
        sh "docker login -u reddysbrahma -p ${dockerHubPwd}"
     }
     sh "docker push reddysbrahma/my-app:${artifact}"
   }
   stage('Remove Old Containers'){
    sshagent(['dev-server']) {
      try{
        def sshCmd = 'ssh -o StrictHostKeyChecking=no ec2-user@172.31.94.51'
        def dockerRM = 'docker rm -f my-app'
        sh "${sshCmd} ${dockerRM}"
      }catch(error){

      }
    }
  }
   stage('Run Container on Dev Server'){
     def dockerRun = "docker run -p 8080:8080 -d --name my-app reddysbrahma/my-app:${artifact}"
     sshagent(['dev-server']) {
       sh "ssh -o StrictHostKeyChecking=no ec2-user@172.31.94.51 ${dockerRun}"
     }
   }
}
