convert src/pic0001.jpg src/pic0002.jpg src/pic0003.jpg src/pic0004.jpg src/pic0005.jpg -poly '0.01,1 0.01,1 0.01,1 0.01,1 0.01,1' intermediate/pass1_0001.jpg
convert src/pic0006.jpg src/pic0007.jpg src/pic0008.jpg src/pic0009.jpg src/pic0010.jpg -poly '0.01,1 0.01,1 0.01,1 0.01,1 0.01,1' intermediate/pass1_0002.jpg
convert src/pic0011.jpg src/pic0012.jpg src/pic0013.jpg src/pic0014.jpg src/pic0015.jpg -poly '0.01,1 0.01,1 0.01,1 0.01,1 0.01,1' intermediate/pass1_0003.jpg
convert src/pic0016.jpg src/pic0017.jpg src/pic0018.jpg src/pic0019.jpg src/pic0020.jpg -poly '0.01,1 0.01,1 0.01,1 0.01,1 0.01,1' intermediate/pass1_0004.jpg
convert src/pic0021.jpg src/pic0022.jpg src/pic0023.jpg src/pic0024.jpg src/pic0025.jpg -poly '0.01,1 0.01,1 0.01,1 0.01,1 0.01,1' intermediate/pass1_0005.jpg
convert src/pic0026.jpg src/pic0027.jpg src/pic0028.jpg src/pic0029.jpg src/pic0030.jpg -poly '0.01,1 0.01,1 0.01,1 0.01,1 0.01,1' intermediate/pass1_0006.jpg
convert src/pic0031.jpg src/pic0032.jpg src/pic0033.jpg src/pic0034.jpg src/pic0035.jpg -poly '0.01,1 0.01,1 0.01,1 0.01,1 0.01,1' intermediate/pass1_0007.jpg
convert src/pic0036.jpg src/pic0037.jpg src/pic0038.jpg src/pic0039.jpg src/pic0040.jpg -poly '0.01,1 0.01,1 0.01,1 0.01,1 0.01,1' intermediate/pass1_0008.jpg
convert src/pic0041.jpg src/pic0042.jpg src/pic0043.jpg src/pic0044.jpg src/pic0045.jpg -poly '0.01,1 0.01,1 0.01,1 0.01,1 0.01,1' intermediate/pass1_0009.jpg
convert src/pic0046.jpg src/pic0047.jpg src/pic0048.jpg src/pic0049.jpg src/pic0050.jpg -poly '0.01,1 0.01,1 0.01,1 0.01,1 0.01,1' intermediate/pass1_0010.jpg
convert src/pic0051.jpg src/pic0052.jpg src/pic0053.jpg src/pic0054.jpg src/pic0055.jpg -poly '0.01,1 0.01,1 0.01,1 0.01,1 0.01,1' intermediate/pass1_0011.jpg
convert src/pic0056.jpg src/pic0057.jpg src/pic0058.jpg src/pic0059.jpg src/pic0060.jpg -poly '0.01,1 0.01,1 0.01,1 0.01,1 0.01,1' intermediate/pass1_0012.jpg
convert src/pic0061.jpg src/pic0062.jpg src/pic0063.jpg src/pic0064.jpg src/pic0065.jpg -poly '0.01,1 0.01,1 0.01,1 0.01,1 0.01,1' intermediate/pass1_0013.jpg
convert src/pic0066.jpg src/pic0067.jpg src/pic0068.jpg src/pic0069.jpg src/pic0070.jpg -poly '0.01,1 0.01,1 0.01,1 0.01,1 0.01,1' intermediate/pass1_0014.jpg
convert src/pic0071.jpg src/pic0072.jpg src/pic0073.jpg src/pic0074.jpg src/pic0075.jpg -poly '0.01,1 0.01,1 0.01,1 0.01,1 0.01,1' intermediate/pass1_0015.jpg
convert src/pic0076.jpg src/pic0077.jpg src/pic0078.jpg src/pic0079.jpg src/pic0080.jpg -poly '0.01,1 0.01,1 0.01,1 0.01,1 0.01,1' intermediate/pass1_0016.jpg
convert src/pic0081.jpg src/pic0082.jpg src/pic0083.jpg src/pic0084.jpg src/pic0085.jpg -poly '0.01,1 0.01,1 0.01,1 0.01,1 0.01,1' intermediate/pass1_0017.jpg
convert src/pic0086.jpg src/pic0087.jpg src/pic0088.jpg src/pic0089.jpg src/pic0090.jpg -poly '0.01,1 0.01,1 0.01,1 0.01,1 0.01,1' intermediate/pass1_0018.jpg
convert src/pic0091.jpg src/pic0092.jpg src/pic0093.jpg src/pic0094.jpg src/pic0095.jpg -poly '0.01,1 0.01,1 0.01,1 0.01,1 0.01,1' intermediate/pass1_0019.jpg
convert src/pic0096.jpg src/pic0097.jpg src/pic0098.jpg src/pic0099.jpg src/pic0100.jpg -poly '0.01,1 0.01,1 0.01,1 0.01,1 0.01,1' intermediate/pass1_0020.jpg
convert intermediate/pass1_0001.jpg intermediate/pass1_0002.jpg intermediate/pass1_0003.jpg intermediate/pass1_0004.jpg intermediate/pass1_0005.jpg -poly '1,1 1,1 1,1 1,1 1,1' intermediate/pass2_0001.jpg
convert intermediate/pass1_0006.jpg intermediate/pass1_0007.jpg intermediate/pass1_0008.jpg intermediate/pass1_0009.jpg intermediate/pass1_0010.jpg -poly '1,1 1,1 1,1 1,1 1,1' intermediate/pass2_0002.jpg
convert intermediate/pass1_0011.jpg intermediate/pass1_0012.jpg intermediate/pass1_0013.jpg intermediate/pass1_0014.jpg intermediate/pass1_0015.jpg -poly '1,1 1,1 1,1 1,1 1,1' intermediate/pass2_0003.jpg
convert intermediate/pass1_0016.jpg intermediate/pass1_0017.jpg intermediate/pass1_0018.jpg intermediate/pass1_0019.jpg intermediate/pass1_0020.jpg -poly '1,1 1,1 1,1 1,1 1,1' intermediate/pass2_0004.jpg
convert intermediate/pass2_0001.jpg intermediate/pass2_0002.jpg intermediate/pass2_0003.jpg intermediate/pass2_0004.jpg -poly '1,1 1,1 1,1 1,1' final_rendered.jpg