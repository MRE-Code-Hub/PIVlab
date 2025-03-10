function histdraw_Callback(~, ~, ~)
handles=gui.gethand;
currentframe=floor(get(handles.fileselector, 'value'));
resultslist=gui.retr('resultslist');
if size(resultslist,2)>=currentframe && numel(resultslist{1,currentframe})>0
	x=resultslist{1,currentframe};
	y=resultslist{2,currentframe};
	typevector=resultslist{5,currentframe};
	if size(resultslist,1)>6 %filtered exists
		if size(resultslist,1)>10 && numel(resultslist{10,currentframe}) > 0 %smoothed exists
			u=resultslist{10,currentframe};
			v=resultslist{11,currentframe};
			typevector=resultslist{9,currentframe}; %von smoothed
		else
			u=resultslist{7,currentframe};
			if size(u,1)>1
				v=resultslist{8,currentframe};
				typevector=resultslist{9,currentframe}; %von smoothed
			else
				u=resultslist{3,currentframe};
				v=resultslist{4,currentframe};
				typevector=resultslist{5,currentframe};
			end
		end
	else
		u=resultslist{3,currentframe};
		v=resultslist{4,currentframe};
	end
	ismean=gui.retr('ismean');
	if    numel(ismean)>0
		if ismean(currentframe)==1 %if current frame is a mean frame, typevector is stored at pos 5
			typevector=resultslist{5,currentframe};
		end
	end

	u(typevector==0)=nan;
	v(typevector==0)=nan;

	calu=gui.retr('calu');calv=gui.retr('calv');
	calxy=gui.retr('calxy');
	x=reshape(x,size(x,1)*size(x,2),1);
	y=reshape(y,size(y,1)*size(y,2),1);
	u=reshape(u,size(u,1)*size(u,2),1);
	v=reshape(v,size(v,1)*size(v,2),1);
	choice_plot=get(handles.hist_select,'value');
	current=get(handles.hist_select,'string');
	current=current{choice_plot};
	h=figure;
	screensize=get( 0, 'ScreenSize' );
	rect = [screensize(3)/4-300, screensize(4)/2-250, 600, 500];
	set(h,'position', rect);
	set(h,'numbertitle','off','menubar','none','toolbar','figure','dockcontrols','off','name',['Histogram ' current ', frame ' num2str(currentframe)],'tag', 'derivplotwindow');
	nrofbins=str2double(get(handles.nrofbins, 'string'));
	if choice_plot==1
		[n, xout]=hist(u*calu-gui.retr('subtr_u'),nrofbins); %#ok<*HIST>
		xdescript='velocity (u)';
	elseif choice_plot==2
		[n, xout]=hist(v*calv-gui.retr('subtr_v'),nrofbins);
		xdescript='velocity (v)';
	elseif choice_plot==3
		[n, xout]=hist(sqrt((u*calu-gui.retr('subtr_u')).^2+(v*calv-gui.retr('subtr_v')).^2),nrofbins);
		xdescript='velocity magnitude';
	elseif choice_plot==4 %sub-pixels

		number=[u;v];
		frac = mod(abs(number),1);

		[n, xout]=hist(frac,nrofbins);
		xdescript='sub-pixel';
	end

	h2=bar(xout,n);
	set (gca, 'xgrid', 'on', 'ygrid', 'on', 'TickDir', 'in')
	if (gui.retr('calu')==1 || gui.retr('calu')==-1) && gui.retr('calxy')==1
		xlabel([xdescript ' [px/frame]']);
	else %calibrated
		displacement_only=gui.retr('displacement_only');
		if ~isempty(displacement_only) && displacement_only == 1
			xlabel([xdescript ' [m/frame]']);
		else
			xlabel([xdescript ' [m/s]']);
		end
	end
	ylabel('frequency');
end

