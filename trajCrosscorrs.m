pChPEs = [abs(est(1).chPE),abs(est(2).chPE),abs(est(4).chPE),abs(est(9).chPE)];
nChPEs = [abs(est(3).chPE),abs(est(5).chPE),abs(est(6).chPE),abs(est(7).chPE),abs(est(8).chPE),abs(est(10).chPE)];
pChPES_means = mean(pChPEs,2);
nChPES_means = mean(nChPEs,2);
figure;
crosscorr(pChPES_means,nChPES_means);

pPEs_L2 = [abs(est(1).PE_L2),abs(est(2).PE_L2),abs(est(4).PE_L2),abs(est(9).PE_L2)];
nPEs_L2 = [abs(est(3).PE_L2),abs(est(5).PE_L2),abs(est(6).PE_L2),abs(est(7).PE_L2),abs(est(8).PE_L2),abs(est(10).PE_L2)];
pPEs_L2_means = mean(pPEs_L2,2);
nPEs_L2_means = mean(nPEs_L2,2);
figure;
crosscorr(pPEs_L2_means,nPEs_L2_means)

pPEs_L3 = [abs(est(1).PE_L3),abs(est(2).PE_L3),abs(est(4).PE_L3),abs(est(9).PE_L3)];
nPEs_L3 = [abs(est(3).PE_L3),abs(est(5).PE_L3),abs(est(6).PE_L3),abs(est(7).PE_L3),abs(est(8).PE_L3),abs(est(10).PE_L3)];
pPEs_L3_means = mean(pPEs_L3,2);
nPEs_L3_means = mean(nPEs_L3,2);
figure;
crosscorr(pPEs_L3_means,nPEs_L3_means)

ppwPEs_L2 = [abs(est(1).pwPE_L2),abs(est(2).pwPE_L2),abs(est(4).pwPE_L2),abs(est(9).pwPE_L2)];
npwPEs_L2 = [abs(est(3).pwPE_L2),abs(est(5).pwPE_L2),abs(est(6).pwPE_L2),abs(est(7).pwPE_L2),abs(est(8).pwPE_L2),abs(est(10).pwPE_L2)];
ppwPEs_L2_means = mean(ppwPEs_L2,2);
npwPEs_L2_means = mean(npwPEs_L2,2);
figure;
crosscorr(ppwPEs_L2_means,npwPEs_L2_means)

ppwPEs_L3 = [abs(est(1).pwPE_L3),abs(est(2).pwPE_L3),abs(est(4).pwPE_L3),abs(est(9).pwPE_L3)];
npwPEs_L3 = [abs(est(3).pwPE_L3),abs(est(5).pwPE_L3),abs(est(6).pwPE_L3),abs(est(7).pwPE_L3),abs(est(8).pwPE_L3),abs(est(10).pwPE_L3)];
ppwPEs_L3_means = mean(ppwPEs_L3,2);
npwPEs_L3_means = mean(npwPEs_L3,2);
figure;
crosscorr(ppwPEs_L3_means,npwPEs_L3_means)