
#include "opencvmex.hpp"

#define _DO_NOT_EXPORT
#if defined(_DO_NOT_EXPORT)
#define DllExport  
#else
#define DllExport __declspec(dllexport)
#endif


///////////////////////////////////////////////////////////////////////////
// Check inputs
///////////////////////////////////////////////////////////////////////////
void checkInputs(int nrhs, const mxArray *prhs[])
{    
	const mwSize * tdims, *fdims;
        
    // Check number of inputs
    if (nrhs != 1)
    {
        mexErrMsgTxt("Incorrect number of inputs. Function expects 2 inputs.");
    }
    
    // Check input dimensions
    tdims = mxGetDimensions(prhs[0]);
    fdims = mxGetDimensions(prhs[1]);
    
    if (mxGetNumberOfDimensions(prhs[0])>2)
    {
        mexErrMsgTxt("Incorrect number of dimensions. First input must be a matrix.");
    }
    
    //if (mxGetNumberOfDimensions(prhs[1])>2)
    //{
    //    mexErrMsgTxt("Incorrect number of dimensions. Second input must be a matrix.");
    //}
    
    //if (tdims[0] > fdims[0])
    //{
    //    mexErrMsgTxt("Template should be smaller than image.");
    //}
    
    //if (tdims[1] > fdims[1])
    //{
    //    mexErrMsgTxt("Template should be smaller than image.");
    //}    
    
	// Check image data type
    if (!mxIsUint8(prhs[0]))
    {
        mexErrMsgTxt("Template and image must be UINT8.");
    }
}


///////////////////////////////////////////////////////////////////////////
// Main entry point to a MEX function
///////////////////////////////////////////////////////////////////////////
void mexFunction(int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[])
{  
	// Check inputs to mex function
    checkInputs(nrhs, prhs);
    
    // Convert mxArray inputs into OpenCV types
    cv::Ptr<cv::Mat> imageCV = ocvMxArrayToImage_uint8(prhs[0], true);
    //cv::Ptr<cv::Mat> imgCV         = ocvMxArrayToImage_uint8(prhs[1], true);
    
    // Allocate output matrix
    int outRows = imageCV->rows;
    int outCols = imageCV->cols;

    cv::Mat outCV((int)outRows, (int)outCols, CV_32FC1);
    
    // Run the OpenCV template matching routine
    cv::medianBlur(imageCV, imageCV, 3);
    cv::threshold(imageCV,imageCV, 0, 255, cv::THRESH_BINARY | cv::THRESH_OTSU);
    cv::Mat elem = cv::getStructuringElement(cv::MORPH_RECT, cv::Size(5, 5));
    cv::morphologyEx(imageCV, imageCV, cv::MORPH_CLOSE, elem);
    cv::adaptiveThreshold(imageCV ,imageCV, 255,cv::ADAPTIVE_THRESH_GAUSSIAN_C, cv::THRESH_BINARY_INV,kernel_size,2);
    //cv::matchTemplate(*imgCV, *templateImgCV, outCV, CV_TM_CCOEFF_NORMED );
    
    // Put the data back into the output MATLAB array
    plhs[0] = ocvMxArrayFromImage_single(imageCV);
}
