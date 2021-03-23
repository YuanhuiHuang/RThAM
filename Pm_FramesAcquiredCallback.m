function Pm_FramesAcquiredCallback(PmVid, MetaData)
% LOCALFRAMESACQUIREDCALLBACK FramesAcquiredFcn callback for custom format logging.
%
%    WRITEIATFRAME is configured by IATCONFIGURELOGGING to be a VIDEOINPUT
%    object's FramesAcquiredFcn callback.  It retrieves a frame with the
%    object's GETDATA method and then writes it to the file created by the
%    LOCALSTARTCALLBACK method.  Data is written in UINT8 format.
%
%    See also IATCONFIGURELOGGING, GETDATA, LOCALSTARTCALLBACK, VIDEOINPUT.

% Retrieve the file id for the current file.
% fid = PmVid.UserData;
% disp(num2str(islogging(PmVid)))
% Write the frame.
% fwrite(fid, getdata(PmVid, 1), 'uint16');

% TiffFileName = ['C:\Pictures\20190221\vShort_GFP10xFish10dpm_4\' 'S_PM',num2str(MetaData.Data.FrameNumber) '.tif'];
% Tiffoptions.message   = false;
% saveastiff(getdata(PmVid,1), TiffFileName, Tiffoptions);

if MetaData.Data.FrameNumber == 5000
    disp('5000 frames - memory almost full !')
elseif MetaData.Data.FrameNumber == 6400
    stop(PmVid);
end
MetaData



