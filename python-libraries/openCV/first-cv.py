import cv2
image=cv2.imread('D:/Practical/py-libraries-practice/openCV/sloth.jpg')
# We will calculate the region of interest
# by slicing the pixels of the image
a = image[100:100, 200:10000]
cv2.imshow("A", a)
cv2.waitKey(0)
