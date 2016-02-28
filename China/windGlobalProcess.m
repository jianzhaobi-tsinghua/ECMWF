function windGlobalProcess(year)

%% Select nc files
dirname_sfc_in=['/home/bijianzhao/bjz_tmp/China/China036Daily/sfc/',num2str(year),'/'];
dirname_mdl_in=['/home/bijianzhao/bjz_tmp/China/China036Daily/mdl/',num2str(year),'/'];
dirname_out=['/home/bijianzhao/bjz_tmp/China/China036Hourly/',num2str(year),'/'];
sfcfilenames=dir([dirname_sfc_in,'*.nc']);
mdlfilenames=dir([dirname_mdl_in,'*.nc']);
invFileName='/home/bijianzhao/bjz_tmp/China/China036Daily/inv/invariant.nc';

% date
monthname={'01','02','03','04','05','06','07','08','09','10','11','12'};
monthday=zeros(1,12);
for month_i=1:12
    monthday(month_i)=eomday(year,month_i);
end


filenum=0;

for month_i=1:12
    
    %create month dir
    monthPath=[dirname_out,monthname{month_i},'/'];
    eval(['mkdir ',monthPath]);
    for file_i=1:monthday(month_i)
        
        %% Preprocessing
        filenum=filenum+1;
        
        %Create Day Path
        if file_i<10
            dayStr=['0',num2str(file_i)];
        else
            dayStr=num2str(file_i);
        end
        dayPath=[monthPath,'/',dayStr,'/','netcdf_complete/'];
        eval(['mkdir ',dayPath]);
        
        %Surface file
        sFileName=[dirname_sfc_in,sfcfilenames(filenum).name];
        %Model file
        mFileName=[dirname_mdl_in,mdlfilenames(filenum).name];
        [~,subname,~]=fileparts(mFileName);
        
        
        disp(mFileName);
        
        
        %% Data preparation
        
        %Constants
        g=9.80665;
        Rd=287.05;
        
        %Surface height
        z=ncread(invFileName,'z');
        height_sfc=z/g;
        
        %Surface pressure
        pressure_sfc=ncread(sFileName,'sp');
        %Surface temperature
        temperature_sfc=ncread(sFileName,'t2m');
        
        %Model temperature
        temperature=ncread(mFileName,'t');
        %Model vorticity
        rel_vorticity=ncread(mFileName,'vo');
        %Wind
        u_wind=ncread(mFileName,'u');
        v_wind=ncread(mFileName,'v');
        lon=ncread(mFileName,'longitude');
        lat=ncread(mFileName,'latitude');
        level=ncread(mFileName,'level');
        
        %Parameter a and b url: http://www.ecmwf.int/en/forecasts/documentation-and-support/60-model-levels
        hyam=[10209.500977,8802.356445,7438.803223,6144.314941,4941.77832,3850.91333,2887.696533,2063.779785,1385.912598,855.361755,467.333588,210.39389,65.889244,7.367743,0,0];
        hybm=[0.635547,0.683269,0.728786,0.771597,0.811253,0.847375,0.879657,0.907884,0.93194,0.951822,0.967645,0.979663,0.98827,0.994019,0.99763,1];
        model_layer=level-45;
        
        %% Data process
        
        %Date and time
        date_str=subname(1:8);
        date=str2double(date_str);
        filename_out={[dayPath,date_str,'_00_complete.nc'],[dayPath,date_str,'_06_complete.nc'],...
            [dayPath,date_str,'_12_complete.nc'],[dayPath,date_str,'_18_complete.nc']};
        time=[0,60000,120000,180000];
        
        for utc_i=1:4
            
            %Surface level
            temperature_sfc_utc=temperature_sfc(:,:,utc_i);
            pressure_sfc_utc=pressure_sfc(:,:,utc_i);
            
            %Model level
            temperature_utc=temperature(:,:,:,utc_i);
            u_out=u_wind(:,:,:,utc_i);
            v_out=v_wind(:,:,:,utc_i);
            hor_ws_out=sqrt(u_out.^2+v_out.^2);
            hor_wd_out=atan2d(u_out,v_out);
            hor_wd_out(hor_wd_out<0)=hor_wd_out(hor_wd_out<0)+360; %make the degrees into [0,360]
            
            %Pressure Calculation
            pressure_utc=zeros(size(temperature_utc));
            for i=1:size(model_layer,1)
                pressure_utc(:,:,i)=0.5*(hyam(i+1)+hyam(i))+0.5*(hybm(i+1)+hybm(i))*pressure_sfc_utc;
            end
            
            %Height Calculation
            height_utc=zeros(size(temperature_utc));
            for i=size(model_layer,1):-1:1
                if i==size(model_layer,1)  %For the bottom layer
                    height_utc(:,:,i)=height_sfc+1./g.*(pressure_sfc_utc-pressure_utc(:,:,i))./pressure_utc(:,:,i).*Rd.*temperature_utc(:,:,i);
                else
                    height_utc(:,:,i)=height_utc(:,:,i+1)+1./g.*(pressure_utc(:,:,i+1)-pressure_utc(:,:,i))./pressure_utc(:,:,i).*Rd.*temperature_utc(:,:,i);
                end
            end
            
            
            %% Create nc files
            % date
            nccreate(filename_out{utc_i},'date','Datatype','int32','Dimensions',{'time',1},'Format','classic');
            ncwrite(filename_out{utc_i},'date',date);
            ncwriteatt(filename_out{utc_i},'date','long_name','calendar date of the data');
            ncwriteatt(filename_out{utc_i},'date','units','YYYYMMDD');
            
            % time_utc
            nccreate(filename_out{utc_i},'time_utc','Datatype','int32','Dimensions',{'time',1},'Format','classic');
            ncwrite(filename_out{utc_i},'time_utc',time(utc_i));
            ncwriteatt(filename_out{utc_i},'time_utc','long_name','time of the day');
            ncwriteatt(filename_out{utc_i},'time_utc','units','HHMMSS');
            
            % longitude
            nccreate(filename_out{utc_i},'longitude','Datatype','single','Dimensions',{'longitude',size(lon,1)},'Format','classic');
            ncwrite(filename_out{utc_i},'longitude',lon);
            ncwriteatt(filename_out{utc_i},'longitude','long_name','longitude coordinate at pixel midpoints');
            ncwriteatt(filename_out{utc_i},'longitude','units','degrees east');
            
            % latitude
            nccreate(filename_out{utc_i},'latitude','Datatype','single','Dimensions',{'latitude',size(lat,1)},'Format','classic');
            ncwrite(filename_out{utc_i},'latitude',lat);
            ncwriteatt(filename_out{utc_i},'latitude','long_name','latitude coordinate at pixel midpoints');
            ncwriteatt(filename_out{utc_i},'latitude','units','degrees north');
            
            % model_layer
            nccreate(filename_out{utc_i},'model_layer','Datatype','int16','Dimensions',{'level',size(model_layer,1)},'Format','classic');
            ncwrite(filename_out{utc_i},'model_layer',model_layer);
            ncwriteatt(filename_out{utc_i},'model_layer','long_name','hybrid level at layer midpoints');
            ncwriteatt(filename_out{utc_i},'model_layer','units','level');
            ncwriteatt(filename_out{utc_i},'model_layer','formula','pressure=hyam+hybm*pressure_sfc');
            ncwriteatt(filename_out{utc_i},'model_layer','description','model layer 0 is the highest altitude of the data set');
            ncwriteatt(filename_out{utc_i},'model_layer','standard_name','hybrid_sigma_pressure');
            
            % hyam
            nccreate(filename_out{utc_i},'hyam','Datatype','single','Dimensions',{'coefficient_level',size(hyam,2)},'Format','classic');
            ncwrite(filename_out{utc_i},'hyam',hyam);
            ncwriteatt(filename_out{utc_i},'hyam','long_name','hybrid pressure coordinate a');
            ncwriteatt(filename_out{utc_i},'hyam','units','Pa');
            
            % hybm
            nccreate(filename_out{utc_i},'hybm','Datatype','single','Dimensions',{'coefficient_level',size(hybm,2)},'Format','classic');
            ncwrite(filename_out{utc_i},'hybm',hybm);
            ncwriteatt(filename_out{utc_i},'hybm','long_name','hybrid pressure coordinate b');
            ncwriteatt(filename_out{utc_i},'hybm','units','dimensionless');
            
            % pressure_sfc
            nccreate(filename_out{utc_i},'pressure_sfc','Datatype','single','Dimensions',{'longitude',size(lon,1),'latitude',size(lat,1)},'Format','classic');
            ncwrite(filename_out{utc_i},'pressure_sfc',pressure_sfc_utc);
            ncwriteatt(filename_out{utc_i},'pressure_sfc','long_name','surface pressure');
            ncwriteatt(filename_out{utc_i},'pressure_sfc','units','Pa');
            
            % height_sfc
            nccreate(filename_out{utc_i},'height_sfc','Datatype','single','Dimensions',{'longitude',size(lon,1),'latitude',size(lat,1)},'Format','classic');
            ncwrite(filename_out{utc_i},'height_sfc',height_sfc);
            ncwriteatt(filename_out{utc_i},'height_sfc','long_name','surface altitude above sea level');
            ncwriteatt(filename_out{utc_i},'height_sfc','units','m');
            
            % temperature_sfc
            nccreate(filename_out{utc_i},'temperature_sfc','Datatype','single','Dimensions',{'longitude',size(lon,1),'latitude',size(lat,1)},'Format','classic');
            ncwrite(filename_out{utc_i},'temperature_sfc',temperature_sfc_utc);
            ncwriteatt(filename_out{utc_i},'temperature_sfc','long_name','2m temperature (surface)');
            ncwriteatt(filename_out{utc_i},'temperature_sfc','units','K');
            
            % temperature
            nccreate(filename_out{utc_i},'temperature','Datatype','single','Dimensions',{'longitude',size(lon,1),'latitude',size(lat,1),'level',size(model_layer,1)},'Format','classic');
            ncwrite(filename_out{utc_i},'temperature',temperature_utc);
            ncwriteatt(filename_out{utc_i},'temperature','long_name','temperature');
            ncwriteatt(filename_out{utc_i},'temperature','units','K');
            
            % rel_vorticity
            nccreate(filename_out{utc_i},'rel_vorticity','Datatype','single','Dimensions',{'longitude',size(lon,1),'latitude',size(lat,1),'level',size(model_layer,1)},'Format','classic');
            ncwrite(filename_out{utc_i},'rel_vorticity',rel_vorticity(:,:,:,utc_i));
            ncwriteatt(filename_out{utc_i},'rel_vorticity','long_name','relative vorticity');
            ncwriteatt(filename_out{utc_i},'rel_vorticity','units','s**-1');
            
            % u_wind
            nccreate(filename_out{utc_i},'u_wind','Datatype','single','Dimensions',{'longitude',size(lon,1),'latitude',size(lat,1),'level',size(model_layer,1)},'Format','classic');
            ncwrite(filename_out{utc_i},'u_wind',u_out);
            ncwriteatt(filename_out{utc_i},'u_wind','long_name','longitudinal wind, positive = westerly wind');
            ncwriteatt(filename_out{utc_i},'u_wind','units','m s**-1');
            
            % v_wind
            nccreate(filename_out{utc_i},'v_wind','Datatype','single','Dimensions',{'longitude',size(lon,1),'latitude',size(lat,1),'level',size(model_layer,1)},'Format','classic');
            ncwrite(filename_out{utc_i},'v_wind',v_out);
            ncwriteatt(filename_out{utc_i},'v_wind','long_name','latitudinal wind, positive = southerly wind');
            ncwriteatt(filename_out{utc_i},'v_wind','units','m s**-1');
            
            % hor_windspeed
            nccreate(filename_out{utc_i},'hor_windspeed','Datatype','single','Dimensions',{'longitude',size(lon,1),'latitude',size(lat,1),'level',size(model_layer,1)},'Format','classic');
            ncwrite(filename_out{utc_i},'hor_windspeed',hor_ws_out);
            ncwriteatt(filename_out{utc_i},'hor_windspeed','long_name','horizontal windspeed');
            ncwriteatt(filename_out{utc_i},'hor_windspeed','units','m s**-1');
            ncwriteatt(filename_out{utc_i},'hor_windspeed','formula','sqrt(u_wind**2+v_wind**2)');
            
            % hor_winddir
            nccreate(filename_out{utc_i},'hor_winddir','Datatype','single','Dimensions',{'longitude',size(lon,1),'latitude',size(lat,1),'level',size(model_layer,1)},'Format','classic');
            ncwrite(filename_out{utc_i},'hor_winddir',hor_wd_out);
            ncwriteatt(filename_out{utc_i},'hor_winddir','long_name','horizontal winddirection');
            ncwriteatt(filename_out{utc_i},'hor_winddir','units','degrees (north=0)');
            ncwriteatt(filename_out{utc_i},'hor_winddir','formula','atan(u_wind,v_wind)*180./pi');
            
            % pressure
            nccreate(filename_out{utc_i},'pressure','Datatype','single','Dimensions',{'longitude',size(lon,1),'latitude',size(lat,1),'level',size(model_layer,1)},'Format','classic');
            ncwrite(filename_out{utc_i},'pressure',pressure_utc);
            ncwriteatt(filename_out{utc_i},'pressure','long_name','pressure');
            ncwriteatt(filename_out{utc_i},'pressure','units','Pa');
            ncwriteatt(filename_out{utc_i},'pressure','formula','pressure_i=0.5*((hyam_i+1)+(hyam_i))+0.5*((hybm_i+1)+(hybm_i))*pressure_sfc');
            
            % height
            nccreate(filename_out{utc_i},'height','Datatype','single','Dimensions',{'longitude',size(lon,1),'latitude',size(lat,1),'level',size(model_layer,1)},'Format','classic');
            ncwrite(filename_out{utc_i},'height',height_utc);
            ncwriteatt(filename_out{utc_i},'height','long_name','altitude above sea level');
            ncwriteatt(filename_out{utc_i},'height','units','m');
            ncwriteatt(filename_out{utc_i},'height','formula','height_i=(height_i+2)+(((pressure_i+2)-(pressure_i))/(g*(pressure_i+1))*Rd*(temperature_i+1)');
            
            
        end
        
    end
    
end

%% Visualization
%{
for i=1:15
    h(i)=mean(mean(height_utc(:,:,i)));
end

disp(h);

pcolor(pressure_utc(:,:,15));
shading flat
%}
