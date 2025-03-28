function makevideo(data, gridx, gridy, vidHeight, vidWidth, xlimits, ylimits, mode)
    if strcmp(mode, 'pcolor')
        numberOfFrames = size(data, 3);
    elseif strcmp(mode, 'streamslice') || strcmp(mode, 'quiverC2D')
        numberOfFrames = size(data{1}, 3);
    else
        disp('Mode not known');
        return;
    end

    t = linspace(0, numberOfFrames/30, numberOfFrames);
    hFigure = figure;
    
    % Set up the movie structure.
    % Preallocate movie, which will be an array of structures.
    % First get a cell array with all the frames.
    allTheFrames = cell(numberOfFrames,1);
    allTheFrames(:) = {zeros(vidHeight, vidWidth, 3, 'uint8')};

    % Next get a cell array with all the colormaps.
    allTheColorMaps = cell(numberOfFrames,1);
    allTheColorMaps(:) = {zeros(256, 3)};

    % Now combine these to make the array of structures.
    myMovie = struct('cdata', allTheFrames, 'colormap', allTheColorMaps);

    % Create a VideoWriter object to write the video out to a new, different file.
    % writerObj = VideoWriter('problem_3.avi');
    % open(writerObj);
    % Need to change from the default renderer to zbuffer to get it to work right.
    % openGL doesn't work and Painters is way too slow.
    set(gcf, 'renderer', 'zbuffer');

    % Create the movie.
    % After this loop starts, BE SURE NOT TO RESIZE THE WINDOW AS IT'S SHOWING THE FRAMES, or else you won't be able to save it.
    for frameIndex = 1 : numberOfFrames
	    cla reset;
	    % Enlarge figure to full screen.
        %set(gcf, 'Units', 'Normalized', 'Outerposition', [0, 0, 1, 1]);

        if strcmp(mode, 'pcolor')
	        pcolor(gridx, gridy, data(:,:,frameIndex));
            set(gca, 'XDir', 'reverse');
            set(gca,'DataAspectRatio',[1 1 1]);
            xlim(xlimits);
            ylim(ylimits);
            shading interp;
            hold on;
            rectangle('Position', [-1, -0.5, 1, 1], 'Curvature', [1, 1]);
        elseif strcmp(mode, 'streamslice')
            streamslice(gridx, gridy, data{1}(:,:,frameIndex), data{2}(:,:,frameIndex));
            set(gca, 'XDir', 'reverse');
            set(gca,'DataAspectRatio',[1 1 1]);
            xlim(xlimits);
            ylim(ylimits);
            hold on;
            rectangle('Position', [-1, -0.5, 1, 1], 'Curvature', [1, 1]);
        elseif strcmp(mode, 'quiverC2D')
            quiverC2D(gridx, gridy, data{1}(:,:,frameIndex), data{2}(:,:,frameIndex), 1);
            set(gca, 'XDir', 'reverse');
            set(gca,'DataAspectRatio',[1 1 1]);
            xlim(xlimits);
            ylim(ylimits);
            hold on;
            rectangle('Position', [-1, -0.5, 1, 1], 'Curvature', [1, 1]);
        end

	    caption = sprintf('Frame #%d of %d, t = %.1f', frameIndex, numberOfFrames, t(frameIndex));
	    title(caption, 'FontSize', 15);

	    drawnow;
	    thisFrame = getframe(gca);
        
	    % Write this frame out to a new video file.
        % writeVideo(writerObj, thisFrame);
	    myMovie(frameIndex) = thisFrame;

        % Debugging
        % disp(size(thisFrame.cdata));
    end
    % close(writerObj);
    
    %==============================================================================================
    % See if they want to replay the movie.
    message = sprintf('Done creating movie\nDo you want to play it?');
    button = questdlg(message, 'Continue?', 'Yes', 'No', 'Yes');
    drawnow;	% Refresh screen to get rid of dialog box remnants.
    close(hFigure);
    if strcmpi(button, 'Yes')
	    hFigure = figure;
	    % Enlarge figure to full screen.
	    % set(gcf, 'Units', 'Normalized', 'Outerposition', [0, 0, 1, 1]);
	    title('Playing the movie', 'FontSize', 15);
	    % Get rid of extra set of axes that it makes for some reason.
	    axis off;
	    % Play the movie.
	    movie(myMovie);
	    close(hFigure);
    end
    
    %==============================================================================================
    % See if they want to save the movie to an avi file on disk.
    promptMessage = sprintf('Do you want to save this movie to disk?');
    titleBarCaption = 'Continue?';
    button = questdlg(promptMessage, titleBarCaption, 'Yes', 'No', 'Yes');
    if strcmpi(button, 'yes')
	    % Get the name of the file that the user wants to save.
	    % Note, if you're saving an image you can use imsave() instead of uiputfile().
	    startingFolder = pwd;
	    defaultFileName = {'*.avi';'*.mp4';'*.mj2'}; %fullfile(startingFolder, '*.avi');
	    [baseFileName, folder] = uiputfile(defaultFileName, 'Specify a file');
	    if baseFileName == 0
		    % User clicked the Cancel button.
		    return;
	    end
	    fullFileName = fullfile(folder, baseFileName);
	    % Create a video writer object with that file name.
	    % The VideoWriter object must have a profile input argument, otherwise you get jpg.
	    % Determine the format the user specified:
	    [folder, baseFileName, ext] = fileparts(fullFileName);
	    switch lower(ext)
		    case '.jp2'
			    profile = 'Archival';
		    case '.mp4'
			    profile = 'MPEG-4';
		    otherwise
			    % Either avi or some other invalid extension.
			    profile = 'Uncompressed AVI';
	    end
	    writerObj = VideoWriter(fullFileName, profile);
	    open(writerObj);
	    % Write out all the frames.
	    numberOfFrames = length(myMovie);
	    for frameNumber = 1 : numberOfFrames
	       writeVideo(writerObj, myMovie(frameNumber));
	    end
	    close(writerObj);
	    % Display the current folder panel so they can see their newly created file.
	    cd(folder);
	    filebrowser;
	    message = sprintf('Finished creating movie file\n      %s.\n\nDone!', fullFileName);
	    uiwait(helpdlg(message));
        cd(startingFolder);
    else
	    uiwait(helpdlg('Done!'));
    end

