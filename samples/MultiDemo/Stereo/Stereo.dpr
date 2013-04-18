(* /*****************************************************************
  //                       Delphi-OpenCV Demo
  //               Copyright (C) 2013 Project Delphi-OpenCV
  // ****************************************************************
  // Contributor:
  // laentir Valetov
  // email:laex@bk.ru
  // ****************************************************************
  // You may retrieve the latest version of this file at the GitHub,
  // located at git://github.com/Laex/Delphi-OpenCV.git
  // ****************************************************************
  // The contents of this file are used with permission, subject to
  // the Mozilla Public License Version 1.1 (the "License"); you may
  // not use this file except in compliance with the License. You may
  // obtain a copy of the License at
  // http://www.mozilla.org/MPL/MPL-1_1Final.html
  //
  // Software distributed under the License is distributed on an
  // "AS IS" basis, WITHOUT WARRANTY OF ANY KIND, either express or
  // implied. See the License for the specific language governing
  // rights and limitations under the License.
  ******************************************************************* *)
// JCL_DEBUG_EXPERT_GENERATEJDBG OFF
// JCL_DEBUG_EXPERT_INSERTJDBG OFF
// JCL_DEBUG_EXPERT_DELETEMAPFILE OFF
program Stereo;

{$APPTYPE CONSOLE}
{$R *.res}

uses
  System.SysUtils,
  uLibName in '..\..\..\include\uLibName.pas',
  highgui_c in '..\..\..\include\highgui\highgui_c.pas',
  core_c in '..\..\..\include\core\core_c.pas',
  Core.types_c in '..\..\..\include\core\Core.types_c.pas',
  imgproc.types_c in '..\..\..\include\imgproc\imgproc.types_c.pas',
  imgproc_c in '..\..\..\include\imgproc\imgproc_c.pas',
  legacy in '..\..\..\include\legacy\legacy.pas',
  calib3d in '..\..\..\include\calib3d\calib3d.pas',
  imgproc in '..\..\..\include\imgproc\imgproc.pas',
  haar in '..\..\..\include\objdetect\haar.pas',
  objdetect in '..\..\..\include\objdetect\objdetect.pas',
  tracking in '..\..\..\include\video\tracking.pas',
  Core in '..\..\..\include\core\core.pas';

Const
  Image_Left = 'StereoSample\Aloe\view0.png';
  Image_Right = 'StereoSample\Aloe\view1.png';
  // ������c��� ��������
  ndisparity = 16;
  // ������c��� ��������
  mIter = 2;

Type
  TDoubleArray = array [0 .. 15] of Double;
  pDoubleArray = ^TDoubleArray;

Var
  image_: pIplImage = nil;
  image1_: pIplImage = nil;
  image_g: pIplImage = nil;
  image1_g: pIplImage = nil;
  disparity_left: pCvMat;
  disparity_right: pCvMat;
  size: TCvSize;
  state: pCvStereoGCState;
  disparity_left_visual: pCvMat;
  Q: pCvMat;
  _3dImage: pIplImage;

begin
  try
    // �������� ��c����� ��������
    image_ := cvLoadImage(Image_Left, 1);
    image1_ := cvLoadImage(Image_Right, 1);
    // c������� �������������� �����������
    image_g := cvCreateImage(cvSize(image_^.width, image_^.height), 8, 1);
    image1_g := cvCreateImage(cvSize(image_^.width, image_^.height), 8, 1);
    size := cvGetSize(image_);
    // c������� ������
    disparity_left := cvCreateMat(size.height, size.width, CV_16S);
    disparity_right := cvCreateMat(size.height, size.width, CV_16S);
    // ������� ����������� � ��������� c�����
    cvCvtColor(image_, image_g, CV_BGR2GRAY);
    cvCvtColor(image1_, image1_g, CV_BGR2GRAY);
    // ������� ��������� ���������� c�����������
    //
    state := cvCreateStereoGCState(ndisparity, mIter);
    // ���������� �c������ ������� c�����������, ������������ ������� 3d
    cvFindStereoCorrespondenceGC(image_g, image1_g, disparity_left, disparity_right, state, 0);
    cvReleaseStereoGCState(state);
    // ����� ������� � ����
    disparity_left_visual := cvCreateMat(size.height, size.width, CV_8U);
    cvConvertScale(disparity_left, disparity_left_visual, -16);
    cvSave('result\disparity.png', disparity_left_visual);
    cvSaveImage('result\disparity.jpg', disparity_left_visual);

    Q := cvCreateMat(4, 4, CV_64F);
    pDoubleArray(Q^.data)[0] := 1;
    pDoubleArray(Q^.data)[1] := 0;
    pDoubleArray(Q^.data)[2] := 0;
    pDoubleArray(Q^.data)[3] := -327.73883438110352;

    pDoubleArray(Q^.data)[4] := 0;
    pDoubleArray(Q^.data)[5] := 1;
    pDoubleArray(Q^.data)[6] := 0;
    pDoubleArray(Q^.data)[7] := -239.84486865997314;

    pDoubleArray(Q^.data)[8] := 0;
    pDoubleArray(Q^.data)[9] := 0;
    pDoubleArray(Q^.data)[10] := 0;
    pDoubleArray(Q^.data)[11] := 524.04542174159019;

    pDoubleArray(Q^.data)[12] := 0;
    pDoubleArray(Q^.data)[13] := 0;
    pDoubleArray(Q^.data)[14] := -0.30009508961926923;
    pDoubleArray(Q^.data)[15] := 1.2438668093184739;

    _3dImage := cvCreateImage(size, IPL_DEPTH_32F, 3);
    cvReprojectImageTo3D(disparity_left_visual, _3dImage, Q);
    cvSave('result\disparity1.png', _3dImage);
    cvSaveImage('result\disparity1.jpg', _3dImage);
  except
    on E: Exception do
      Writeln(E.ClassName, ': ', E.Message);
  end;

end.
