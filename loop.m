%% loop equations
%   calculating some variables...
[T, SpeedOfSound, P, rho] = atmosisa(Altitude);
KinematicViscosity = mu(rho);
ShaftRPS = ShaftRPM/60;                             %[RPM]
omega = 2*pi*ShaftRPS;                              %[1/s]

if DiaOptimizer == 0
    Rprop = DesignDia/2;
else
    MaxTipSpeed = MaxTipMachNumber*SpeedOfSound;
    Rprop = sqrt((MaxTipSpeed^2)-(FlightSpeed^2))/omega;
end

Dprop = Rprop*2;
J = FlightSpeed/((ShaftRPS)*Dprop);
r = linspace(Dspinner/2, Dprop/2, NumberOfStation); % [m]
Pc = (ShaftPower/(rho*(ShaftRPS^3)*(Dprop^5)));

RefErr = 1e-5;
Err = 1;
zeta =  0;
epsilon = zeros(1,NumberOfStation);
alpha = 0;
Cd = 0;
FirstIterationFlagger = 0;

for i = 1:NumberOfStation
    while Err>RefErr
        xi = r./Rprop;
        lambda = FlightSpeed./(omega.*r);
        x_r = xi/lambda;
        x = xi./lambda(end);
        phi_t = lambda(end)*(1+(zeta/2));
        phi = atan((tan(phi_t))./xi);
        f = (NumberOfBlades/2).*((1-xi))/(sin(phi_t));
        F = (2/pi).*acos(exp(-f));
        G_r = F.*x_r.*cos(phi).*sin(phi);
        a = (zeta./2).*(((1+cos(2.*phi))./(2))).*(1-(epsilon.*tan(phi)));
        aprime = (zeta./(2*x(i)))*((cos(phi(i)))*(sin(phi(i))))*(1+(epsilon(i)/tan(phi(i))));
        
        W = (FlightSpeed.*(1+a))./sin(phi);
        Mach = W/SpeedOfSound;
        G = F.*x.*cos(phi).*sin(phi);
        gamma = (2.*pi.*(FlightSpeed^2).*zeta.*G)./(NumberOfBlades.*omega);
        c = (gamma.*2)./(W.*DCLi);
        Re = ((W.*c)./KinematicViscosity);
        
       run("get_xfoil_data.m");
        
        FirstIterationFlagger = 1;
        
        for ii = 1:NumberOfStation
            
            I1_prime = 4*xi(ii)*G_r(ii)*(1-(epsilon(ii)*tan(phi(ii))));
            I2_prime = mean(lambda)*(I1_prime/2*xi(ii))*(1+epsilon(ii)/tan(phi(ii)))*sin(phi(ii))*cos(phi(ii));
            
            J1_prime = 4*xi(ii)*G_r(ii)*(1+(epsilon(ii)/tan(phi(ii))));
            J2_prime = (J1_prime/2)*(1-epsilon(ii)*tan(phi(ii)))*((cos(phi(ii)))^2);
            OUT_I1(ii) = I1_prime;
            OUT_I2(ii) = I2_prime;
            OUT_J1(ii) = J1_prime;
            OUT_J2(ii) = J2_prime;
        end
        
        I1_int = cumtrapz(xi, OUT_I1);
        I2_int = cumtrapz(xi, OUT_I2);
        J1_int = cumtrapz(xi, OUT_J1);
        J2_int = cumtrapz(xi, OUT_J2);
        I1 = I1_int(end)/2;
        I2 = I2_int(end)/2;
        J1 = J1_int(end)/2;
        J2 = J2_int(end)/2;
        
%         PcforEta = (J1*zeta)+(J2*(zeta^2));
        TcforEta = (I1*zeta)-(I2*(zeta^2));
        eta = (TcforEta/Pc);
        newzeta_ps = -1*(J1/(2*J2))+ sqrt(((J1/(2*J2))^2)+(Pc/J2));
        Tc = (Pc*eta)/(J);
        Trust = Tc*(ShaftRPS^2)*(Dprop^4)*rho;
        Err = abs(newzeta_ps-zeta);
        zeta = newzeta_ps;
        
    end
    zeta = 0;
    Err = 1;
    OUT_zeta(i) = newzeta_ps;
    OUT_phi(i) = phi(i);
    OUT_phi_t = phi_t;
    OUT_beta(i) = phi(i)+OUT_alpha(i);
    OUT_a = a;
    OUT_aprime(i) = aprime;
    OUT_Mach = Mach;
    OUT_c = c;
    OUT_Re = Re;
    eta;
    Trust;
end

LdivideD = 1./epsilon;

for af = 1:NumberOfStation
    AF = (100000/16)*(OUT_c(af)/Dprop)*((xi(af))^3);
    OUT_AF(af) = AF;
end
AF_int = cumtrapz(xi, OUT_AF);
TAF = (AF_int(end))*NumberOfBlades;
BAF = (AF_int(end));


[xData_phi, yData_phi] = prepareCurveData( 1:NumberOfStation, OUT_phi );
[fitresult_phi, ~] = fit( xData_phi, yData_phi, ft, opts);

GeometricPitchStation = NumberOfStation*0.75;
GeometricPitchBetaAngle = fitresult_phi(GeometricPitchStation)+ fitresult_alpha(GeometricPitchStation);