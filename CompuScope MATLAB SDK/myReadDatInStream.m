fid = fopen('Data_2.dat')
% fid = fopen('Data2ch_1.dat')
% datauint16 = fread(fid,Inf, 'int16',0, 'ieee-le');
% figure,plot(datauint16)
% fclose(fid)

segmentCount = 5;
size2Read = 7808;
channelCount = 2;

datauint16 = zeros(size2Read, segmentCount,channelCount);
sizeHeader = 64;
fileheaders = zeros(sizeHeader, segmentCount);
for iSegmentCount=1:1:segmentCount
    for iChannelCount=1:1:channelCount
        datauint16(:,iSegmentCount,iChannelCount) = fread(fid,size2Read, 'int16',0, 'ieee-le');
    end
    fileheaders(:,iSegmentCount) = fread(fid, sizeHeader, 'int16',0, 'ieee-le')
end

fclose(fid)

figure,plot(datauint16(:,:,1))
figure,plot(datauint16(:,:,2))