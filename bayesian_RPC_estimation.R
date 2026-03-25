# Simulaciones del Rasch Poisson Count Model


setwd(dirname(rstudioapi::getActiveDocumentContext()$path))

###Example: 

#Procedimiennto de simulacion 
# 1. Generate true values and response matrix

rpcm.sim<-function( nitem, npers,tiempos) {
  true.beta <- runif(nitem,0,4.5)   #simulate true difficulty parameters
  true.th   <- rnorm(npers,0.5,1)    #simulate true theta parameters
  
  temp <- matrix( rep( true.th, nitem ), ncol = nitem) 
  par.items <- true.beta + tiempos
  logits <- t( apply( temp , 1, '+', par.items ) )

    # For RPCM:
  mu            <- t( apply( logits, 1, exp ) )
  resp.mu       <- matrix( mu, ncol = nitem)
  response      <- matrix( sapply( c(resp.mu), rpois, n = 1), ncol = nitem )
  # Output:
  output        <- list()
  output$b      <- true.beta
  output$theta  <- true.th
  output$tpo    <- tiempos
  output$resp   <- response
  return(output)
}

nitem <- 30
npers <- 500
tiempos <- rep(15/60,nitem)  #t tiempo que se exige para responder cada pregunta

sim      <- rpcm.sim( nitem, npers,tiempos) 
response <- sim$resp
head(response)
######################

#true
beta    <- sim$b
beta
theta   <- sim$theta
tiempos <- sim$tiempos

#-------------------------------------------------------------------------------

if(!require(R2jags)) install.packages("R2jags");
library(R2jags)
if(!require(coda)) install.packages("coda");
library(coda)

Y <- response
n <- nrow(Y)
k <- ncol(Y)
data_list <- list("Y","n","k")

#PRIOR1

modelrpcm<-"
  model {
 for (i in 1:n){
 for (j in 1:k){
    Y[i , j] ~  dpois (mu[i , j])
  mu [i , j] <- exp( theta[i] + beta[j] + tiempos[j] )
   }
  theta [i] ~ dnorm (0.5 , 1.0)
  }

 for (j in 1:k){
 beta [j] ~ dnorm (0.5 , 2 )
 #prior1
 tiempos [j] <- 0.25
               }
 }
 "
writeLines(modelrpcm, con = "modelrpcm.txt")

burn=5000
thin=10
iter=10000

params <- c("beta","theta")
nChains = 2
burnInSteps = burn
thinSteps = thin
nIter=iter

install.packages("tictoc")
library(tictoc)
tic()
jags.rpcm.res <- jags(data = data_list, inits = NULL, parameters.to.save = params,
                       model.file = "modelrpcm.txt", n.chains = nChains, n.iter = nIter,
                       n.burnin = burnInSteps, n.thin = thinSteps)
toc()
jags.rpcm.res

#-------------------------------------------------------------------------------
library(lme4)

# Convertir la matriz de conteos a formato largo
library(tidyr)
Y.df <- data.frame(Y)
nombre <- "pers1"
for(i in 2:500){
  nombre <- c(nombre,paste("pers",i,sep=""))
}

nombre1 <- "it1"
for(i in 2:30){
  nombre1 <- c(nombre1,paste("it",i,sep=""))
}

Y.df <- cbind(nombre,Y.df)
colnames(Y.df) <- c("persona",nombre1)


Y.long <- pivot_longer(Y.df, cols=2:31, names_to="item", values_to="aciertos")
Y.long$item <- factor(Y.long$item)
Y.long$persona <- factor(Y.long$persona)

# Ajustar el modelo utilizando lme4
fit <- glmer(aciertos ~ tiempos + item + (1|persona), data=Y.long, family=poisson)
summary(fit)
# Obtener los valores estimados de theta y beta
beta.mle <- fixef(fit)
theta.mle <- ranef(fit)$persona[,1]



#-------------------------------------------------------------------------------

beta.post <-apply(jags.rpcm.res$BUGSoutput$sims.list$beta,2,mean)
itemspar  <- cbind(beta,beta.post,beta.mle)

theta.post <-apply(jags.rpcm.res$BUGSoutput$sims.list$theta,2,mean)
thetapar   <- cbind(theta,theta.post,theta.mle)

write.csv2(itemspar,"itemspar.csv")
write.csv2(thetapar,"thetapar.csv")

#-------------------------------------------------------------------------------
txtStop()
save.image("RPCMsimuyesti.RData")
