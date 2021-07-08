//Model started by Faith in Feb 2020 based on Lizzie's notes 
// Modified by Deirdre based on the rangers model 

// running a joint model to try and see how trait variation might help 
    //predict phenology. BAsed off Lizzie's joint model exquation 

//priors are centred around values from Deirdre's similation code: fakedata_3parm_1trait.R   

data {
    int < lower = 1 > Nph; // Sample size for forcing 
    int < lower = 1 > n_spec; // number of random effect levels (species) 
    int < lower = 1, upper = n_spec > species[Nph]; // id of random effect (species)
 
    vector[Nph] yPhenoi; // Outcome phenology
    vector[Nph] forcei; // predictor forcing 
    vector[Nph] chilli; // predictor forcing 

    vector[n_spec] alphaTraitSp; // species level trait data

}

parameters{

    real alphaForceSp[n_spec]; //the distribution of species forcing values
    real muForceSp; // the mean of the effect of forcing
    real <lower = 0> sigmaForceSp; //variation around the mean of the effect of forcing 

    real alphaChillSp[n_spec]; //the distribution of species forcing values
    real muChillSp; // the mean of the effect of forcing
    real <lower = 0> sigmaChillSp; //variation around the mean of the effect of forcing 

    real alphaPhenoSp[n_spec]; //the species level intercept 
    real muPhenoSp; // 
    real <lower = 0> sigmaPhenoSp; 
    
    real betaTraitxForce;
    real betaTraitxChill;
    
    // general varience/error
    real <lower =0> sigmapheno_y; // overall variation accross observations
}

transformed parameters{
    real betaForceSp[n_spec];     //species level beta forcing 
    real betaChillSp[n_spec];     //species level beta forcing 

    //get betaForceSp values for each species
    for (i in 1:n_spec){
        betaForceSp[i] = alphaForceSp[i] + betaTraitxForce * alphaTraitSp[i];
    }
    
    for (i in 1:n_spec){
        betaChillSp[i] = alphaChillSp[i] + betaTraitxChill * alphaTraitSp[i];
    }
}

model{ 
    //priors - level 1
sigmapheno_y ~ normal(5, 3); // 

    //priors level 2
    sigmaForceSp ~ normal(5, 0.1); //
    muForceSp ~ normal(-1, 0.5);//
    alphaForceSp ~ normal(muForceSp, sigmaForceSp);  //

    sigmaChillSp ~ normal(5, 0.5); //
    muChillSp ~ normal(-2, 0.5);//
    alphaChillSp ~ normal(muChillSp, sigmaChillSp);  //
   
    sigmaPhenoSp ~ normal(10, 0.5); // sigma.pheno.sp =2  
    muPhenoSp ~ normal(150, 10);  // mu.pheno.sp = 150, try (30, 10) , estpecially for 150, 5 is very low
    alphaPhenoSp ~ normal(muPhenoSp, sigmaPhenoSp);//
    
    betaTraitxForce ~ normal(2,1);
    betaTraitxChill ~ normal(2,1);
    
    //likelihood 
            for (i in 1:Nph){
    yPhenoi[i] ~ normal( alphaPhenoSp[species[i]] + betaForceSp[species[i]] * forcei[i] + betaChillSp[species[i]] * chilli[i], sigmapheno_y);
        }
}

generated quantities {
    real ypred[Nph];
 
   for (i in 1:Nph) { // now over writing this with the sample dist, but this is already done for you in the transformed para block 
    ypred[i] = alphaPhenoSp[species[i]] + alphaForceSp[species[i]] * forcei[i] + alphaChillSp[species[i]] * chilli[i];
    ypred[i] = normal_rng(ypred[i], sigmapheno_y);
   }


} // The posterior predictive distribution