function curves(AirfoilFilename, r, OUT_beta, OUT_c, Dshank, LSpinner, ZeroStation2one, NumberOfStation, XStationOffset,YStationOffset, FigureOn)

%CURVES Summary of this function goes here
%   Detailed explanation goes here

% warning off

if FigureOn == 1
    hold on
end

mkdir curve_files

NoseConeShape = 0; % Zero is von karman shape.
RSpinner = r(1);
SpinnerOffset = 0.01;
NumberOfZeroStation = 5;
ShankFormtoBladePercent = 0.12; % To what percent of the wing should the fuselage form be extended?

for i = 1:NumberOfStation    
    
    txt2table = readtable(AirfoilFilename);
    matrix = txt2table{:,:};
    matrix(1,:) = [];
    AirfoilBaseX = matrix(:,1);
    AirfoilBaseY = matrix(:,2);
    
   
    
    Xoffset = (AirfoilBaseX) - XStationOffset;
    Yoffset = (AirfoilBaseY) - YStationOffset;
    
    ShankFormEndedStation = round(NumberOfStation*ShankFormtoBladePercent);
    YAxisLength = max(Yoffset)-min(Yoffset);
    SoftTransition = linspace(YAxisLength*2, 1, ShankFormEndedStation);
    
    BladeThicknessCorrection = ones(1, length(Xoffset));
    for iii = 1:ShankFormEndedStation
        BladeThicknessCorrection(iii) = SoftTransition(iii);
    end
    
    Xs= Xoffset*OUT_c(i);
    Ys= Yoffset*OUT_c(i)/BladeThicknessCorrection(i);
    
    ang = -OUT_beta(i);
    Xsr =  Xs.*cos(ang) + Ys.*sin(ang);
    Ysr = -Xs*sin(ang) + Ys*cos(ang);
    Xr = Xsr + XStationOffset;
    Yr = Ysr + YStationOffset;
    Zr = (r(i)*ones(1,length(Xr)));
    
    if i == 1
        ZeroStationRanges = linspace(0,(ZeroStation2one/10)*5,NumberOfZeroStation);
        for iiii = 1:5
            ZeroStationRange = ZeroStationRanges(iiii);
            CenterX = mean(Xr);
            CenterY = mean(Yr);
            ang = linspace(0, 2*pi, length(Xoffset));
            xp=(Dshank/2)*cos(ang);
            yp=(Dshank/2)*sin(ang);
            shankX = CenterX+xp;
            shankY = CenterY+yp;
            shankZ = r(1)-(ZeroStation2one*ones(1,length(ang)))-ZeroStationRange;
            
            if FigureOn == 1
                plot3(shankX,shankY,shankZ);
            end
            
            FileNameCreater = sprintf('curve_files/zero_station_curve_%d',iiii);
            FileName = fopen(FileNameCreater+".txt",'w');
            for ii = 1:length(ang)
                fprintf(FileName,'%12.8f\t',shankX(ii));
                fprintf(FileName,'%12.8f\t',shankY(ii));
                fprintf(FileName,'%12.8f\n',shankZ(ii));
            end
            fclose(FileName);
        end        
        
        xSpinner = linspace(0, LSpinner,200);
        theta = acos(1-(2*xSpinner)/(LSpinner));
        zSpinner = RSpinner*sqrt((theta-sin(2*theta)/2+NoseConeShape*(sin(theta)).^3))/(sqrt(pi));
        ySpinner = zeros(1,length(xSpinner))+CenterY;
        xSpinnerOffset = CenterX-LSpinner+(Dshank/2)+SpinnerOffset;            
        
        FileNameCreater = sprintf('curve_files/spinner_curve');
        FileName = fopen(FileNameCreater+".txt",'w');
        for iiiii = 1:length(xSpinner)
            fprintf(FileName,'%12.8f\t',xSpinner(iiiii)+ xSpinnerOffset);
            fprintf(FileName,'%12.8f\t',ySpinner(iiiii));
            fprintf(FileName,'%12.8f\n',zSpinner(iiiii));
        end
        fclose(FileName);
        if FigureOn == 1
            plot3(xSpinner+xSpinnerOffset,ySpinner,zSpinner)
        end
        
    end
    
    FileNameCreater=sprintf('curve_files/blade_station_curve_%d',i);
    FileName = fopen(FileNameCreater+".txt",'w');
    for i= 1:length(Xr)
        fprintf(FileName,'%12.8f\t',Xr(i));
        fprintf(FileName,'%12.8f\t',Yr(i));
        fprintf(FileName,'%12.8f\n',Zr(i));
    end
    fclose(FileName);
    
    if FigureOn == 1
        plot3(Xr,Yr,Zr)
%         title('Blade Geometry')
        axis('equal');
        view([52 27]);
        xlabel('X [m]');
        ylabel('Y [m]');
        zlabel('Z [m]');
    end
end

% VarName = 'AAAA';
% VarValue = 10;
% assignin('base',VarName,VarValue)


all = [];
for i = 1:21
    FileNameCreater = sprintf('curve_files/blade_station_curve_%d.txt',i);
    txt2table = readtable(FileNameCreater);
    matrix = txt2table{:,:};   
    all = [all; matrix];    
end   

T = table(all);
writetable(T,'curve_files/all_airfoil_points.csv');

fprintf('\n\tCreated curve files. \n')

end



