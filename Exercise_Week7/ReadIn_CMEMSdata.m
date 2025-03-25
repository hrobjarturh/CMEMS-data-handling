% Script to read in data from the Copernicus Marine System (CMEMS)
% Course 25340 Digital Ocean
% Creator: Rafael Gonçalves-Araujo, DTU Aqua
% rafgo@aqua.dtu.dk

clear
clc

% Install the toolboxes
addpath '/Users/hrobjarturh/Documents/DTU/digitalocean/CMEMS-data-handling/Exercise_Week7/m_map'
addpath '/Users/hrobjarturh/Documents/DTU/digitalocean/CMEMS-data-handling/Exercise_Week7/seawater_ver3_3.1'
addpath '/Users/hrobjarturh/Documents/DTU/digitalocean/CMEMS-data-handling/Exercise_Week7/unixtime2mat'

%% Define path (folder) where the NetCDF files are stored

cd '/Users/hrobjarturh/Documents/DTU/digitalocean/CMEMS-data-handling/data/copernicus/cmems_mod_arc_phy_my_topaz4_P1M/'

ncfiles = dir('*.nc'); % creates a table with the information of each NetCDF file in the folder

%% Display content of the files --> check description of each variable

ncdisp(ncfiles(1,1).name)

%% Verify the raw time values being used

% Import the raw time values
raw_time = double(ncread(ncfiles(1,1).name, 'time'));

% Display the raw time values
disp('Raw time values:');
disp(raw_time);

% Display the time units
time_units = ncreadatt(ncfiles(1,1).name, 'time', 'units');
disp(['Time units: ' time_units]);

% Convert raw time to actual dates for verification
if contains(time_units, 'seconds since')
    ref_date_str = extractAfter(time_units, 'seconds since ');
    ref_date_str = strtok(ref_date_str, '+');  % Remove timezone if present
    ref_date = datetime(ref_date_str, 'InputFormat', 'yyyy-MM-dd''T''HH:mm:ss');
    converted_time = ref_date + seconds(raw_time);
elseif contains(time_units, 'days since')
    ref_date_str = extractAfter(time_units, 'days since ');
    ref_date_str = strtok(ref_date_str, '+');  % Remove timezone if present
    ref_date = datetime(ref_date_str, 'InputFormat', 'yyyy-MM-dd''T''HH:mm:ss');
    converted_time = ref_date + days(raw_time);
elseif contains(time_units, 'hours since')
    ref_date_str = extractAfter(time_units, 'hours since ');
    ref_date_str = strtok(ref_date_str, '+');  % Remove timezone if present
    ref_date = datetime(ref_date_str, 'InputFormat', 'yyyy-MM-dd''T''HH:mm:ss');
    converted_time = ref_date + hours(raw_time);
else
    error('Unsupported time units: %s', time_units);
end

time = converted_time;

% Display the converted dates to verify
disp('Converted dates:');
disp(datestr(time));

% Create string dates for naming/saving files accordingly at end
timee = datevec(time); % if you want to convert to datevec

[r c] = size(timee);

for i=1:r
    year(i,:) = num2str(timee(i,1));
    if timee(i,2)<=9
        month(i,:) = ['0' num2str(timee(i,2))];
    else
        month(i,:) = num2str(timee(i,2));
    end
    
    if timee(i,3)<=9
        day(i,:) = ['0' num2str(timee(i,3))];
    else
        day(i,:) = num2str(timee(i,3));
    end
end

clear r c timee i 

day = string(day);
month = string(month);
year = string(year);

disp('Days:');
disp(day)
disp('Months:');
disp(month)
disp('Years:');
disp(year)


%% Read in the variables (not in a loop, since we only have one NetCDF file)
% index (1,1) because there is only one file, toerhwise we would have to create a loop


depth = double(ncread(ncfiles(1,1).name,'depth')); % depth (m)
lat = double(ncread(ncfiles(1,1).name,'latitude'));  % latitude (°N)
lon = double(ncread(ncfiles(1,1).name,'longitude'));  % longitude (°E)
sal = double(ncread(ncfiles(1,1).name,'so'));  % salinity
tpot = double(ncread(ncfiles(1,1).name,'thetao'));  % potential temperature (°C)
mld = double(ncread(ncfiles(1,1).name,'mlotst'));  % Ocean mixed layer thickness defined by sigma theta (m)
sic = double(ncread(ncfiles(1,1).name,'siconc'));  % sea ice area fraction
si_vx = double(ncread(ncfiles(1,1).name,'vxsi'));  % Eastward sea ice velocity (m/s)
si_vy = double(ncread(ncfiles(1,1).name,'vysi'));  % Northward sea ice velocity (m/s)
sisnthick = double(ncread(ncfiles(1,1).name,'sisnthick'));  % sea ice snow thickness (m)


% No uncertanties are provided in this product, therefore we are not loading them

%% Reduce size of temp and sal --> only one layer in depth

tpot = squeeze(tpot);
sal = squeeze(sal);

%% Examples of plots --> surface maps showing all variables in one figure

[Plg,Plt]=meshgrid(lon,lat); % Create a grid based on lat and lon coordinates

% Loop through each time step
for i = 1:size(time,1)
    % Create a figure with 7 subplots (arranged in a 3x3 grid with one empty spot)
    figure('color','w', 'Position', [100, 100, 1200, 1000]);
    sgtitle(sprintf('Arctic Ocean Data - %s', datestr(time(i,1),'mmm yyyy')), 'FontSize', 18, 'FontWeight', 'bold');
    
    % 1. Temperature
    subplot(3,3,1)
    m_proj('stereographic','lat',90,'lon',0,'radius',38);
    m_pcolor(Plg,Plt,squeeze(tpot(:,:,i)'));
    shading flat;
    m_coast('patch',[0.5 0.5 0.5]);
    m_grid('tickdir','out', 'fontsize', 8);
    h=colorbar('location','eastoutside');
    set(get(h,'xlabel'),'String','Temperature (°C)','fontsize',10,'fontweight','bold');
    title('Temperature', 'FontSize', 12, 'FontWeight', 'bold');
    
    % 2. Salinity
    subplot(3,3,2)
    m_proj('stereographic','lat',90,'lon',0,'radius',38);
    m_pcolor(Plg,Plt,squeeze(sal(:,:,i)'));
    shading flat;
    m_coast('patch',[0.5 0.5 0.5]);
    m_grid('tickdir','out', 'fontsize', 8);
    h=colorbar('location','eastoutside');
    set(get(h,'xlabel'),'String','Salinity','fontsize',10,'fontweight','bold');
    title('Salinity', 'FontSize', 12, 'FontWeight', 'bold');
    
    % 3. Mixed Layer Depth
    subplot(3,3,3)
    m_proj('stereographic','lat',90,'lon',0,'radius',38);
    m_pcolor(Plg,Plt,squeeze(mld(:,:,i)'));
    shading flat;
    m_coast('patch',[0.5 0.5 0.5]);
    m_grid('tickdir','out', 'fontsize', 8);
    h=colorbar('location','eastoutside');
    set(get(h,'xlabel'),'String','Depth (m)','fontsize',10,'fontweight','bold');
    title('Mixed Layer Depth', 'FontSize', 12, 'FontWeight', 'bold');
    
    % 4. Sea Ice Concentration
    subplot(3,3,4)
    m_proj('stereographic','lat',90,'lon',0,'radius',38);
    m_pcolor(Plg,Plt,squeeze(sic(:,:,i)'));
    shading flat;
    m_coast('patch',[0.5 0.5 0.5]);
    m_grid('tickdir','out', 'fontsize', 8);
    h=colorbar('location','eastoutside');
    set(get(h,'xlabel'),'String','Fraction','fontsize',10,'fontweight','bold');
    title('Sea Ice Concentration', 'FontSize', 12, 'FontWeight', 'bold');
    
    % 5. Sea Ice Snow Thickness
    subplot(3,3,5)
    m_proj('stereographic','lat',90,'lon',0,'radius',38);
    m_pcolor(Plg,Plt,squeeze(sisnthick(:,:,i)'));
    shading flat;
    m_coast('patch',[0.5 0.5 0.5]);
    m_grid('tickdir','out', 'fontsize', 8);
    h=colorbar('location','eastoutside');
    set(get(h,'xlabel'),'String','Thickness (m)','fontsize',10,'fontweight','bold');
    title('Sea Ice Snow Thickness', 'FontSize', 12, 'FontWeight', 'bold');
    
    % 6. Sea Ice Velocity (Eastward)
    subplot(3,3,6)
    m_proj('stereographic','lat',90,'lon',0,'radius',38);
    m_pcolor(Plg,Plt,squeeze(si_vx(:,:,i)'));
    shading flat;
    m_coast('patch',[0.5 0.5 0.5]);
    m_grid('tickdir','out', 'fontsize', 8);
    h=colorbar('location','eastoutside');
    set(get(h,'xlabel'),'String','Velocity (m/s)','fontsize',10,'fontweight','bold');
    title('Eastward Sea Ice Velocity', 'FontSize', 12, 'FontWeight', 'bold');
    
    % 7. Sea Ice Velocity (Northward)
    subplot(3,3,7)
    m_proj('stereographic','lat',90,'lon',0,'radius',38);
    m_pcolor(Plg,Plt,squeeze(si_vy(:,:,i)'));
    shading flat;
    m_coast('patch',[0.5 0.5 0.5]);
    m_grid('tickdir','out', 'fontsize', 8);
    h=colorbar('location','eastoutside');
    set(get(h,'xlabel'),'String','Velocity (m/s)','fontsize',10,'fontweight','bold');
    title('Northward Sea Ice Velocity', 'FontSize', 12, 'FontWeight', 'bold');
    
    % 8. Sea Ice Velocity (Combined as vectors)
    subplot(3,3,8)
    m_proj('stereographic','lat',90,'lon',0,'radius',38);
    % Calculate velocity magnitude for color
    w = sqrt(si_vx(:,:,i).^2 + si_vy(:,:,i).^2);
    m_pcolor(Plg,Plt,w');
    hold on
    % Plot vectors (use a subset for clarity)
    skip = 5; % Plot every 5th vector
    m_quiver(Plg(1:skip:end,1:skip:end), Plt(1:skip:end,1:skip:end), ...
             squeeze(si_vx(1:skip:end,1:skip:end,i))', ...
             squeeze(si_vy(1:skip:end,1:skip:end,i))', 1.5, 'k');
    shading flat;
    m_coast('patch',[0.5 0.5 0.5]);
    m_grid('tickdir','out', 'fontsize', 8);
    h=colorbar('location','eastoutside');
    set(get(h,'xlabel'),'String','Magnitude (m/s)','fontsize',10,'fontweight','bold');
    title('Sea Ice Velocity Vectors', 'FontSize', 12, 'FontWeight', 'bold');
    hold off
    
    % Add a pause to view the first figure
    if i==1
        pause
    end
    
    % Save the figure
    saveas(gcf, sprintf('/Users/hrobjarturh/Documents/DTU/digitalocean/CMEMS-data-handling/Exercise_Week7/plots/all_variables_%s%s.png', year(i,1), month(i,1)));
end

clear i w h

%% Extract time series from a given polygon

[Plg,Plt]=meshgrid(lon,lat); % Create a grid based on lon and lat coordinates

% type in the coordinates for the polygon to extract the time series
pol_coords = [11.398105 79.020265
    20.742337 80.502043
    20.347510 81.740907
    12.450977 82.858314
    0.079741 81.279370
    3.369963 79.797591
    11.398105 79.020265];  % remember to repeat the first coordinates at the end

% use inpolygon to find the data within the polygon
Pol = inpolygon(Plt,Plg,pol_coords(:,2),pol_coords(:,1));

for i = 1:size(time,1)
    a = sal(:,:,i); a = a(find(Pol==1)); % finding the values within the polygon for each scene
    ts.sal(i,1) = mean(mean(a,'omitnan'),'omitnan');
    
    a = tpot(:,:,i); a = a(find(Pol==1)); % finding the values within the polygon for each scene
    ts.tpot(i,1) = mean(mean(a,'omitnan'),'omitnan');
    
    a = mld(:,:,i); a = a(find(Pol==1)); % finding the values within the polygon for each scene
    ts.mld(i,1) = mean(mean(a,'omitnan'),'omitnan');
    
    a = sic(:,:,i); a = a(find(Pol==1)); % finding the values within the polygon for each scene
    ts.sic(i,1) = mean(mean(a,'omitnan'),'omitnan');
    
    a = si_vx(:,:,i); a = a(find(Pol==1)); % finding the values within the polygon for each scene
    ts.si_vx(i,1) = mean(mean(a,'omitnan'),'omitnan');
    
    a = si_vy(:,:,i); a = a(find(Pol==1)); % finding the values within the polygon for each scene
    ts.si_vy(i,1) = mean(mean(a,'omitnan'),'omitnan');
end

clear a i Pol

%% Plotting the time series

figure
plot(time,ts.tpot,'-k','LineWidth',4)
grid on; grid minor; box on
ylabel('Pot. Temperature (°C)')
set(gca,'FontSize',16,'FontWeight','Bold','FontName','Calibri')

%% Plotting the polygon on a map

figure
m_proj('stereographic','lat',90,'lon',0,'radius',38);
m_pcolor(Plg,Plt,squeeze(tpot(:,:,3)')); % lon, lat, variable to plot
hold on
shading flat;
m_gshhs_h('patch',[0.5 0.5 0.5]); %attribute gray to land
m_gshhs_h('color','k');
m_plot(pol_coords(:,1),pol_coords(:,2),'-k','LineWidth',2)
m_grid('fancy','tickdir','out');
%[a,b]=m_etopo2('contour',[-100 -200 -500 -2000],'color',[0 0 0]); % %contour selected bathymetry
%clabel(a,b,'fontsize',8) % controlling font size in the bathymetry contours
h=colorbar('location','eastoutside');
set(get(h,'xlabel'),'String','Temperature (°C)','fontsize',16,'fontweight','bold');
set(gca,'fontsize',16) % increase font size
title(strcat('Temperature (',datestr(time(3,1),'mmm yyyy'),')'))
hold off

%% Saving the file

save 'path/Results_CMEMS_exercise.mat' depth lat lon mld sal si_vx si_vy time tpot ts
