node{
 def server = Artifactory.newServer url: 'http://IPforJfrog:8081/artifactory', username: 'admin', password: 'admin'
      def rtMaven = Artifactory.newMavenBuild()
      def mvnHome = tool 'maven-3'
      def buildInfo = Artifactory.newBuildInfo()
	  
	  
	
   stage('SCM Checkout'){
       git credentialsId: 'git-brahma', url: 'https://github.com/shishirdevops/Demo2.git'
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
    stage('SonarQube analysis') {
    def scannerHome = tool 'sonar-scanner';
    withSonarQubeEnv('sonar') {
      sh "${scannerHome}/bin/sonar-scanner"
	 sh '/opt/apache-maven-3.5.4/bin/mvn org.sonarsource.scanner.maven:sonar-maven-plugin:3.2:sonar'
    }
   }
   sh " sh gettheversion.sh > commandResult"
   artifact = readFile('commandResult').trim()
   stage('Build Docker Image'){
     sh "docker build -t shishir91/my-app:${artifact} ."
   }
   stage('Push Docker Image'){
     withCredentials([string(credentialsId: 'docker-pwd', variable: 'dockerHubPwd')]) {
        sh "docker login -u shishir91 -p ${dockerHubPwd}"
     }
     sh "docker push shishir91/my-app:${artifact}"
   }
   stage('Remove Old Containers'){
    sshagent(['dev-server']) {
      try{
        def sshCmd = 'ssh -o StrictHostKeyChecking=no ec2-user@IP'
        def dockerRM = 'docker rm -f my-app'
        sh "${sshCmd} ${dockerRM}"
      }catch(error){

      }
    }
  }
   stage('Run Container on Dev Server'){
     def dockerRun = "docker run -p 8080:8080 -d --name my-app shishir91/my-app:${artifact}"
     sshagent(['dev-server']) {
       sh "ssh -o StrictHostKeyChecking=no ec2-user@IP ${dockerRun}"
     }
   }
}
