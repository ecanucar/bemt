clc

points = 5;

ShaftRPM_Range = linspace(ShaftRPM*0.1,ShaftRPM,points)
ShaftRPS_Range = ShaftRPM_Range/60;
Trust = 0.0498.*(ShaftRPS_Range.^2).*(Dprop.^4).*1.227435
ShaftRPS = ShaftRPS_Range;


figure
hold on
plot(ShaftRPM_Range, Trust)
legend(legeng_isim_1,legeng_isim_2);
xlabel('n [RPM]');
ylabel( 'T [N]');
grid on
hold off


