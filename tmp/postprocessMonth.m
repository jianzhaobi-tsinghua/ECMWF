function postprocessMonth(year,monthnum)

yearstr=num2str(year);

dirname_in=['/public/temp/BJZ/ERA-Interim/Europe036Daily/',yearstr,'/'];
dirname_out=['/public/temp/BJZ/ERA-Interim/Europe036Hourly/',yearstr,'/'];
%dirname_in='';
%dirname_out='res/';
filenames=dir([dirname_in,'*.nc']);

monthname={'01','02','03','04','05','06','07','08','09','10','11','12'};


%% Create
filenum=0;

for month_i=1:12
    monthPath=[dirname_out,monthname{month_i},'/'];
    eval(['mkdir ',monthPath]);
    for file_i=1:monthnum(month_i)
        
        filenum=filenum+1;
        
        %Create Day Path
        if file_i<10
            dayStr=['0',num2str(file_i)];
        else
            dayStr=num2str(file_i);
        end
        dayPath=[monthPath,'/',dayStr,'/','netcdf_complete/'];
        eval(['mkdir ',dayPath]);
        
        filename=[dirname_in,filenames(filenum).name];
        [~,subname,ext]=fileparts(filename);
        
        disp(filename);
        
        u=ncread(filename,'u');
        v=ncread(filename,'v');
        lon=ncread(filename,'longitude');
        lat=ncread(filename,'latitude');
        level=ncread(filename,'level');
        level=level-45;
        
        %% preprocess
        
        filename_out={[dayPath,subname,'_00.nc'],[dayPath,subname,'_06.nc'],...
            [dayPath,subname,'_12.nc'],[dayPath,subname,'_18.nc']};
        date=str2double(subname(1:8));
        time=[0,60000,120000,180000];
        
        %% Create files
        for out_i=1:4
            
            u_out=u(:,:,:,out_i);
            v_out=v(:,:,:,out_i);
            hor_ws_out=sqrt(u_out.^2+v_out.^2);
            hor_wd_out=atan2d(u_out,v_out);
            hor_wd_out(hor_wd_out<0)=hor_wd_out(hor_wd_out<0)+360; %make the degrees into [0,360]
            
            
            %% date
            nccreate(filename_out{out_i},'date','Datatype','int32','Dimensions',{'time',1},'Format','classic');
            ncwrite(filename_out{out_i},'date',date);
            ncwriteatt(filename_out{out_i},'date','long_name','calendar date of the data');
            ncwriteatt(filename_out{out_i},'date','units','YYYYMMDD');
            
            %% time_utc
            nccreate(filename_out{out_i},'time_utc','Datatype','int32','Dimensions',{'time',1},'Format','classic');
            ncwrite(filename_out{out_i},'time_utc',time(out_i));
            ncwriteatt(filename_out{out_i},'time_utc','long_name','time of the day');
            ncwriteatt(filename_out{out_i},'time_utc','units','HHMMSS');
            
            %% longitude
            nccreate(filename_out{out_i},'longitude','Datatype','single','Dimensions',{'longitude',size(lon,1)},'Format','classic');
            ncwrite(filename_out{out_i},'longitude',lon);
            ncwriteatt(filename_out{out_i},'longitude','long_name','longitude coordinate at pixel midpoints');
            ncwriteatt(filename_out{out_i},'longitude','units','degrees east');
            
            %% latitude
            nccreate(filename_out{out_i},'latitude','Datatype','single','Dimensions',{'latitude',size(lat,1)},'Format','classic');
            ncwrite(filename_out{out_i},'latitude',lat);
            ncwriteatt(filename_out{out_i},'latitude','long_name','latitude coordinate at pixel midpoints');
            ncwriteatt(filename_out{out_i},'latitude','units','degrees north');
            
            %% model_layer
            nccreate(filename_out{out_i},'model_layer','Datatype','int16','Dimensions',{'level',size(level,1)},'Format','classic');
            ncwrite(filename_out{out_i},'model_layer',level);
            ncwriteatt(filename_out{out_i},'model_layer','long_name','hybrid level at layer midpoints');
            ncwriteatt(filename_out{out_i},'model_layer','units','level');
            ncwriteatt(filename_out{out_i},'model_layer','formula','pressure=hyam+hybm*pressure_sfc');
            ncwriteatt(filename_out{out_i},'model_layer','description','model layer 0 is the highest altitude of the data set');
            ncwriteatt(filename_out{out_i},'model_layer','standard_name','hybrid_sigma_pressure');
            
            %% u_wind
            nccreate(filename_out{out_i},'u_wind','Datatype','single','Dimensions',{'longitude',size(lon,1),'latitude',size(lat,1),'level',size(level,1)},'Format','classic');
            ncwrite(filename_out{out_i},'u_wind',u_out);
            ncwriteatt(filename_out{out_i},'u_wind','long_name','latitudinal wind, positive = southerly wind');
            ncwriteatt(filename_out{out_i},'u_wind','units','m s**-1');
            
            %% v_wind
            nccreate(filename_out{out_i},'v_wind','Datatype','single','Dimensions',{'longitude',size(lon,1),'latitude',size(lat,1),'level',size(level,1)},'Format','classic');
            ncwrite(filename_out{out_i},'v_wind',v_out);
            ncwriteatt(filename_out{out_i},'v_wind','long_name','longitudinal wind, positive = westerly wind');
            ncwriteatt(filename_out{out_i},'v_wind','units','m s**-1');
            
            %% hor_windspeed
            nccreate(filename_out{out_i},'hor_windspeed','Datatype','single','Dimensions',{'longitude',size(lon,1),'latitude',size(lat,1),'level',size(level,1)},'Format','classic');
            ncwrite(filename_out{out_i},'hor_windspeed',hor_ws_out);
            ncwriteatt(filename_out{out_i},'hor_windspeed','long_name','horizontal windspeed');
            ncwriteatt(filename_out{out_i},'hor_windspeed','units','m s**-1');
            ncwriteatt(filename_out{out_i},'hor_windspeed','formula','sqrt(u_wind**2+v_wind**2)');
            
            %% hor_winddir
            nccreate(filename_out{out_i},'hor_winddir','Datatype','single','Dimensions',{'longitude',size(lon,1),'latitude',size(lat,1),'level',size(level,1)},'Format','classic');
            ncwrite(filename_out{out_i},'hor_winddir',hor_wd_out);
            ncwriteatt(filename_out{out_i},'hor_winddir','long_name','horizontal winddirection');
            ncwriteatt(filename_out{out_i},'hor_winddir','units','degrees (north=0)');
            ncwriteatt(filename_out{out_i},'hor_winddir','formula','atan(u_wind,v_wind)*180./pi');
            
        end
        
    end
end

end