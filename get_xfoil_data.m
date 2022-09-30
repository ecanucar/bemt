clc
fprintf("    Currently the ncrit value is " + ncrit + "." + '\n');
fprintf('\n');
fprintf('\tStation\t\tzeta\tRe\t\t\tDCLi/Cd\talpha\n');
fprintf('\t-----\t\t-----\t------\t\t------\t-----\n');


if i == 1 && FirstIterationFlagger == 1
    for fff = 1: NumberOfStation
        
        eXcommand_ncrit = sprintf('oper/vpar n %d', ncrit);
        eXcommand_iter = sprintf('oper/iter %d', XfoilIter);
        XfoilResults = xfoilCl(AirfoilFilename, DCLi, Re(fff), Mach(fff), eXcommand_ncrit, eXcommand_iter);
        XfoilResultsCell = struct2cell(XfoilResults);
        alpha = deg2rad(cell2mat(XfoilResultsCell(6)));
        Cd = cell2mat(XfoilResultsCell(8));
        
        if isempty(Cd) || fff == NumberOfStation
            Cd = NaN;
            alpha = NaN;
        end
        
        FormatTitle = ('%9.0f\t%9.4f\t%1.1e\t\t%3.2f\t%1.2f\n');
        fprintf(FormatTitle,fff ,zeta, Re(fff), DCLi/Cd, rad2deg(alpha));
        epsilon(fff) = Cd/DCLi;
        OUT_alpha(fff) = alpha;
    end
    
    ft = fittype( 'poly8' );
    opts = fitoptions( 'Method', 'LinearLeastSquares' );
    opts.Robust = 'Bisquare';
    [xData_epsilon, yData_epsilon] = prepareCurveData( 1:NumberOfStation, epsilon );
    [fitresult_epsilon, ~] = fit( xData_epsilon, yData_epsilon, ft, opts );
    [xData_alpha, yData_alpha] = prepareCurveData( 1:NumberOfStation, OUT_alpha );
    [fitresult_alpha, ~] = fit( xData_alpha, yData_alpha, ft, opts);
    
    if epsilon(1) ~= 0
        plot(fitresult_epsilon, xData_epsilon, yData_epsilon);
        xlabel('Station')
        ylabel('epsilon (Cd/Cl)')
        pause(0.1);
        %                 plot(fitresult_alpha, xData_alpha, yData_alpha);
        %                 xlabel('Station')
        %                 ylabel('alpha [deg]')
        %                 pause(0.1);
        %pause()
    end
    
    
    for eee = 1:NumberOfStation
        epsilon(eee) = fitresult_epsilon(eee);
        OUT_alpha(eee) = fitresult_alpha(eee);
        
        %                 epsilon_ = [59.56 64.02 67.41 69.92 71.78 73.15 74.15 74.85 75.32 75.56 75.61 75.51 75.19 74.66 73.88 72.78 71.24 69.08 65.83 60.27 54.27];
        %                 epsilon = 1./epsilon_;
        %                 phi_ = [54.75 48.83 43.81 39.57 35.97 32.90 30.27 27.99 26.01 24.28 22.75 21.39 20.18 19.10 18.12 17.23 16.43 15.69 15.02 14.40 13.83];
        %                 phi = deg2rad(phi_);
    end
    
else
    fprintf('For stray animals, please put a bowl of water in front of your door.');
end