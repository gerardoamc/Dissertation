run('close_Serial.m')
comPort='com4';% com 42 arduino viejo
[force.s,fserialFlag]=setupSerial(comPort);
%calCo=calibrateForce(force.s);
calCo.g=0.0627;

calCo.offset=0;
load('thermistor_lookup.mat')

format short

%% Open a new figure - add start/stop and close serial buttons
% initialize the figure that will be plot if it does not exist
%clear button
if(~exist('h','var')||~ishandle(h))
    h=figure(1);
    ax=axes('box','on');
end
if (~exist('button','var'))
    button=uicontrol('Style','pushbutton','String','Stop',...
        'pos',[0 0 50 25],'parent',h,...
        'Callback','stop_call_vector','UserData',1);
end
% clos_call function calls everytime it is pressed
if(~exist('button2','var'))
    button=uicontrol('Style','pushbutton','String','Close Serial Port',...
        'pos',[250 0 150 25],'parent',h,...
        'Callback','closeSerial','UserData',1);    
end
    
buf_len=2;
plot_window=60; % 30 data points
% Rolling plot of data
%  buf_len=100;
%  index=1:buf_len;
% force_data=zeros(buf_len,1);
% length_data=zeros(buf_len,1);
tic
% data Collection and plotting
% while the figure window is open
while (get(button,'UserData'))
index=1:buf_len;
% force_data=zeros(buf_len,1);
% length_data=zeros(buf_len,1);
    % Get the new value from acceleometer
    [forces, length, temp1, temp2]=readData(force,calCo, thermistor_lookup);
    forces
    length
    % Update the rolling plot. Append the new reading to the end of the 
    % rolling plot data. Drop the first value
    actual_time=toc;
    force_data(buf_len,1:3)=[buf_len,actual_time, forces];
    length_data(buf_len,1:3)=[buf_len,actual_time, length];
    speed_data(buf_len,1)=buf_len;
    speed_data(buf_len,2)=actual_time;
    speed_data(buf_len,3)=(length_data(buf_len,3)-length_data(buf_len-1,3))/(length_data(buf_len,2)-length_data(buf_len-1,2));
    speed_data_2(buf_len,1)=buf_len;
    speed_data_2(buf_len,2)=actual_time;
    speed_data_2(buf_len,3)=movmean(speed_data(buf_len,3),10);
    temp1_data(buf_len,1:3)=[buf_len,actual_time,temp1];
    temp2_data(buf_len,1:3)=[buf_len,actual_time,temp2];
    if (buf_len<=plot_window) 
    d_min=1;
    t_ini=0;
    else
    d_min=buf_len-plot_window;
    t_ini=(force_data(d_min,2));
    end
    
    subplot(5,1,1);
    plot(force_data(d_min:buf_len,2),force_data(d_min:buf_len,3),'r');
    axis([t_ini ceil(actual_time) min(force_data(d_min:buf_len,3))-5 max(force_data(d_min:buf_len,3))+5]);
    xlabel('time')
    ylabel('F_z(g)')
    
    subplot(5,1,2);
    plot(length_data(d_min:buf_len,2),length_data(d_min:buf_len,3),'r');
    axis([t_ini ceil(actual_time) min(length_data(d_min:buf_len,3))-5 max(length_data(d_min:buf_len,3))+5]);
    xlabel('time')
    ylabel('L_z(mm)')
        
    subplot(5,1,3);
    plot(speed_data(:,2),speed_data(:,3),'r');
%     plot(speed_data_2(:,2),speed_data_2(:,3),'b');
%     axis([t_ini ceil(actual_time) min(speed_data(d_min:buf_len,3))-1 max(speed_data(d_min:buf_len,3))+1]);
     axis([t_ini ceil(actual_time) min(speed_data_2(d_min:buf_len,3))-1 max(speed_data_2(d_min:buf_len,3))+1]);
    xlabel('time')
    ylabel('U_z(mm/s)')
%     subplot(6,1,4);
% %     plot(speed_data(:,2),speed_data(:,3),'r');
%     plot(speed_data_2(:,2),speed_data_2(:,3),'b');
% %     axis([t_ini ceil(actual_time) min(speed_data(d_min:buf_len,3))-1 max(speed_data(d_min:buf_len,3))+1]);
%      axis([t_ini ceil(actual_time) min(speed_data_2(d_min:buf_len,3))-1 max(speed_data_2(d_min:buf_len,3))+1]);
%     xlabel('time')
%     ylabel('U2_z(mm/s)')
    
    
    subplot(5,2,7);
    plot(temp1_data(d_min:buf_len,2),temp1_data(d_min:buf_len,3),'r');
    axis([t_ini ceil(actual_time) 0 300]);
%     plot(temp1_data(:,2),temp1_data(:,3),'r');
%     axis([0 ceil(actual_time) 0 300]);
    xlabel('time')
    ylabel('T1 (C)')
    subplot(5,2,8);
    plot(temp2_data(:,2),temp2_data(:,3),'r');
    axis([0 ceil(actual_time) 0 300]);
    xlabel('time')
    ylabel('T2 (C)')
    drawnow;
    buf_len=buf_len+1;
end

%set ':' for sake of validating vector and csv creation. will need to
%change to '4285:29735'


mean_temp = mean(temp2_data(:,3));    %section of data that corresponds to bulk of print, ok
mean_speed = mean(speed_data_2(:,3));   %section of data that corresponds to bulk of print, ok
mean_force = mean(force_data(:,3));   %section of data that corresponds to bulk of print, NOT OK- data should not be averaged! what else to do?

% d1 = designfilt('lowpassiir','FilterOrder',12, ...
%     'HalfPowerFrequency',0.03,'DesignMethod','butter');
% 
% temp_filt= filtfilt(d1,data(:,2));


to_csv = [mean_temp(:), mean_speed(:), mean_force(:)]   %matrix with all vectors to be outpt to csv

writematrix(to_csv,'temp_speed_force.csv')  %where do we want this csv to be saved to


%% Extra section to create csv using data from print for export and import to python
    %maybe just add this directly above? right after the loop ends!
    
length_values = length_data(:,3);    %vector of length values
diff_length_values = diff(length_values);   %difference in length along vector

eps = .1; %threshold
t_diff = (abs(diff_length_values) >= eps);  % create all ones and zeros vector
d_diff = diff(t_diff);  %difference along ones and zeros path

startIndex = find(d_diff < 0)+1;  
endIndex = find(d_diff > 0)+1;
endIndex(1)=[];         %doing this gets rid of the first zero set from before the print begins

clear length       %need to do this because 'length' is a function, but also has been defined as a variable

final_index = startIndex(end);

if length(startIndex) ~= length(endIndex)
    startIndex(end)=[];
end

duration = endIndex-startIndex+1;

m_zeros = [startIndex,endIndex,duration];
m_zeros_copy = m_zeros;


clear length

for index = length(startIndex):-1:1  
   duration(index);
   if  duration(index) < 80 || duration(index)>125
      m_zeros(index,:) = [];
   end
end

%start
%here is where I add the digital filter section
d2 = designfilt('lowpassiir','FilterOrder',12, ...
    'HalfPowerFrequency',0.002,'DesignMethod','butter');

% y = filtfilt(d2,force_data(:,3));

%temp_data_filtered = filtfilt(d2,temp2_data(:,3));         comment out
%speed_data_filtered = filtfilt(d2,speed_data_2(:,3));      comment out
%force_data_filtered = filtfilt(d2,force_data(:,3));


%mean_force1 = mean(force_data_filtered(m_zeros(1,2):m_zeros(2,1),1));
%mean_force2 = mean(force_data_filtered(m_zeros(2,2):m_zeros(3,1),1));
%mean_force3 = mean(force_data_filtered(m_zeros(3,2):m_zeros(4,1),1));
%mean_force4 = mean(force_data_filtered(m_zeros(4,2):final_index(1),1));
%here is where I end the digital filter section
%end


%mean_temp1 = mean(temp1_data(m_zeros(1,2):m_zeros(2,1),3));
%mean_temp2 = mean(temp1_data(m_zeros(2,2):m_zeros(3,1),3));
%mean_temp3 = mean(temp1_data(m_zeros(3,2):m_zeros(4,1),3));
%mean_temp4 = mean(temp1_data(m_zeros(4,2):final_index(1),3));
%mean_temp5 = mean(temp2_data(m_zeros(5,2):m_zeros(6,1),3));

%mean_speed1 = mean(speed_data_2(m_zeros(1,2):m_zeros(2,1),3));
%mean_speed2 = mean(speed_data_2(m_zeros(2,2):m_zeros(3,1),3));
%mean_speed3 = mean(speed_data_2(m_zeros(3,2):m_zeros(4,1),3));
%mean_speed4 = mean(speed_data_2(m_zeros(4,2):final_index(1),3));
%mean_speed5 = mean(speed_data_2(m_zeros(5,2):m_zeros(6,1),3));

% mean_force1 = mean(force_data(m_zeros(1,2):m_zeros(2,1),3));
% mean_force2 = mean(force_data(m_zeros(2,2):m_zeros(3,1),3));
% mean_force3 = mean(force_data(m_zeros(3,2):m_zeros(4,1),3));
% mean_force4 = mean(force_data(m_zeros(4,2):final_index(1),3));
% %mean_force5 = mean(force_data(m_zeros(5,2):m_zeros(6,1),3));

%mean_temp = [mean_temp1;mean_temp2;mean_temp3;mean_temp4];
%mean_speed = [mean_speed1;mean_speed2;mean_speed3;mean_speed4];
%mean_force = [mean_force1;mean_force2;mean_force3;mean_force4];

%to_csv = [mean_temp(:), mean_speed(:), mean_force(:)];   %matrix with all vectors to be outpt to csv
to_csv = [speed_data_2(:,1), speed_data_2(:,3), force_data(:,3)]; 
to_csv_2 = speed_data;
%writematrix(to_csv,'filtered_speed_force.csv');  %where do we want this csv to be saved to
writematrix(to_csv,'raw_speed_force.csv')
writematrix(to_csv_2,'raw_speed.csv');


%% Section 4:
 
% Troubleshooting section
 
% FORCE PLOTS
 
figure('Name','Force')
 
plot(force_data(:, 1), force_data(:,3))
 
ylim([0 1800])
xlabel('index')
ylabel('Force/g')
%hold on
 
%plot(force_data(:, 1), force_data(:,3))
 
% LENGTH AND SPEED PLOTS
 
figure ('Name','Length & Speed')
 
subplot(2,1,1); plot(length_data(:,1), (length_data(:,3)))
xlabel('index')
ylabel('Length/mm') 
axis tight
 
subplot(2,1,2); plot(speed_data(:,1), (speed_data(:,3)))
xlabel('index')
ylabel('Filament Speed/mm/s') 
 
axis tight
%% Section 5: 
% FORCE v.s. SPEED PLOTS
 
%figure ('Name','NO filter & filter')
 
%xlim([2 5])
scatter(speed_data(:,3),force_data(:,3),'MarkerFaceAlpha',0.2,'MarkerEdgeAlpha',0.2) %Without filter
 
xlabel('Filament Speed/mm/s')
ylabel('Force/g') 
 
%axis tight
 
%subplot(2,1,2); scatter(speed_data(:,3),force_data(:,3),'MarkerFaceAlpha',0.2,'MarkerEdgeAlpha',0.2)%With filter
 
%axis tight


%% 
clear force_data length_data index forces length temp1_data temp2_data speed_data   