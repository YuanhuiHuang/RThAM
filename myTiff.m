function myTiff(ROI,fileParams,IS_TA)


%% interpolation
%     ss = interp3(ROI,'cubic');
%     [X,Y,Z] = size(ss);
%     D_Factor = (Z./(Delta_tt_*SoS*1e6*1e3)*reconParams.GRID_DS./reconParams.GRID_DZ)./2;
%     ss = reshape(ss, X*Y,Z);
% %     ind = [1:1:size(ss,2)]';
% %     ss = (sparse(ceil(ind/D_Factor/10)*10,ind,1)*ss')'; % downsampling the US sequence to be alike TA sequence
%     ss = imresize(ss,[size(ss,1) ceil(size(ss,2)/D_Factor/10)*10]);
%     ss = reshape(ss,[X Y size(ss,2)]);
%% no interpolation
    ROI = ROI./max(ROI(:));
    ss = uint16(ROI.*2^16);
%     ss = (ROI);
%     [X,Y,Z] = size(ss);
%% set file name
if IS_TA
    outputFileName = [fileParams.data fileParams.dataName '\img_stack_TA' '_'  fileParams.reconExt '.tif'];
    if exist(outputFileName,'file')
        files  = dir([fileParams.data fileParams.dataName '\*img_stack_TA' '_'  fileParams.reconExt '*.tif']);
        nFiles = length(files);
        outputFileName = [fileParams.data fileParams.dataName '\img_stack_TA' '_'  fileParams.reconExt '_' num2str(nFiles) '.tif'];
    end
elseif ~IS_TA
    outputFileName = [fileParams.data fileParams.dataName '\img_stack_US' '_'  fileParams.reconExt '.tif'];
    if exist(outputFileName,'file')
        files  = dir([fileParams.data fileParams.dataName '\*img_stack_US' '_'  fileParams.reconExt '*.tif']);
        nFiles = length(files);
        outputFileName = [fileParams.data fileParams.dataName '\img_stack_US' '_'  fileParams.reconExt '_' num2str(nFiles) '.tif'];
    end
end
disp(outputFileName);

% h_Tif = Tiff(outputFileName,'w');
% setTag(h_Tif,'ImageLength',size(ss,1));
% setTag(h_Tif,'ImageWidth',size(ss,2));
% setTag(h_Tif,'ResolutionUnit',Tiff.ResolutionUnit.Centimeter);
% setTag(h_Tif,'XResolution',dy.*1e4);
% setTag(h_Tif,'YResolution',dx.*1e4);
% % setTag(h_Tif,'Photometric',Tiff.Photometric.RGB);
% % setTag(h_Tif,'BitsPerSample',16);
% % % setTag(h_Tif,'SamplesPerPixel',size(ss,3));
% % % setTag(h_Tif,'ExtraSamples',Tiff.ExtraSamples.AssociatedAlpha);
% % setTag(h_Tif,'SamplesPerPixel',4);
% % % setTag(h_Tif,'TileWidth',128);
% % % setTag(h_Tif,'TileLength',128);
% % setTag(h_Tif,'Compression',Tiff.Compression.None);
% % setTag(h_Tif,'PlanarConfiguration',Tiff.PlanarConfiguration.Chunky);
% % setTag(h_Tif,'Software','MATLAB');
% 
% % outputFileName = 'img_stack_US.tif'
% % h_Tif.close();
for K=1:length(ss(1, 1, :))
   imwrite(ss(:, :, K), outputFileName, 'WriteMode', 'append',  'Compression','none');
end

fprintf('\n');