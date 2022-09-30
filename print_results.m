%%
%print
clc
close
fprintf('\n\n');
summaryNames = ["Efficiently","Pc","Tc","Trust [N]","J","TAF","BAF","D [m]" , "Geometric Pitch [deg]"];
summary = table(eta, Pc, Tc, Trust, J, TAF, BAF, Dprop, rad2deg(GeometricPitchBetaAngle) ,'VariableNames',summaryNames);
disp(summary);
fprintf('\n\n');
i = 1:NumberOfStation;
resultsNames = ["i","r [m]","c [m]","alpha [deg]","phi [deg]","L/D","Mach","a","a'","Re x(10^6)"];
results = table(i',r',OUT_c',rad2deg(OUT_alpha)',rad2deg(OUT_phi'),LdivideD',OUT_Mach',OUT_a',OUT_aprime',(Re')/1e6,'VariableNames',resultsNames);
disp(results);

curves(AirfoilFilename, r, OUT_beta, OUT_c, Dshank, LSpinner, ZeroStation2one, NumberOfStation, XStationOffset,YStationOffset, ShowBladeGeometry);

timeElapsed = toc;
fprintf('\n'+"    Calculated in " + timeElapsed + " seconds."+'\n');
