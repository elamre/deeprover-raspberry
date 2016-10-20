clear all
mypi = raspi
RightM=12;
LeftM=13;
configureDigitalPin(mypi,RightM,'output');
configureDigitalPin(mypi,LeftM,'output');
i2csensor = i2cdev(mypi,'i2c-1','0x40');

url = 'http://192.168.2.230:8080/shot.jpg'; 
framesAcquired = 0;
while (framesAcquired <= 200)                   % the vedio will work till the 50 video frames, after that the vedio will stop. You can use while(1) for infinite loop
      data = imread(url); 
      framesAcquired = framesAcquired + 1;    
      diff_im = imsubtract(data(:,:,1), rgb2gray(data));  % subtracting red component from the gray image
      diff_im = medfilt2(diff_im, [3 3]);             % used in image processing to reduce noise and for filtering
      diff_im = im2bw(diff_im,0.18);  
      diff_im = bwareaopen(diff_im,4000);% convert image to binary image
      bw = bwlabel(diff_im, 8);
      stats = regionprops(diff_im, 'BoundingBox', 'Centroid','Extrema');  % measures a set of properties for each connected component in the binary image     
             
      drawnow;
      imshow(data);
      hold on  
      for object = 1:length(stats)
          bb = stats(object).BoundingBox;
          bc = stats(object).Centroid;
          pos = stats(object).Extrema;
          top = pos(1,2);
          but = pos(5,2);
          dis=read(i2csensor,1)
          rectangle('Position',bb,'EdgeColor','b','LineWidth',2)
          plot(bc(1),bc(2), '-m+')  
          a=text(bc(1)+15,bc(2), strcat('X: ', num2str(round(bc(1))), '    Y: ', num2str(round(bc(2)))));
        set(a, 'FontName', 'Arial', 'FontWeight', 'bold', 'FontSize', 12, 'Color', 'yellow');
       
     end
      hold off 
    
end
clear all