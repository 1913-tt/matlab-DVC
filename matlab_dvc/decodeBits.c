//Author:  David Varodayan (varodayan@stanford.edu)
//Date:    May 8, 2006

#include "mex.h"
#include <stdio.h>
#include <math.h>

#define max(a,b) (((a)>(b))?(a):(b))

//C-MEX wrapper
void mexFunction(int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[])
{
    double *LLR_intrinsic, *accumulatedSyndrome, *source, *decoded, *rate, *numErrors;
    char ladderFile[50];
    FILE *fp;
    int n;
    
    LLR_intrinsic = mxGetPr(prhs[0]);
    accumulatedSyndrome = mxGetPr(prhs[1]);
    source = mxGetPr(prhs[2]);
    mxGetString(prhs[3], ladderFile, 50); 
    
    fp = fopen(ladderFile, "r");
    fscanf(fp, "%d", &n);
    fscanf(fp, "%d", &n);
    fclose(fp);    
    
    plhs[0] = mxCreateDoubleMatrix(1, n, mxREAL);
    decoded = mxGetPr(plhs[0]);
    plhs[1] = mxCreateDoubleMatrix(1, 1, mxREAL);
    rate = mxGetPr(plhs[1]);
    plhs[2] = mxCreateDoubleMatrix(1, 1, mxREAL);
    numErrors = mxGetPr(plhs[2]);
    
    decodeBits(LLR_intrinsic, accumulatedSyndrome, source, ladderFile, decoded, rate, numErrors);
}

//decodeBits() finds the minimum rate for which the decoded bitstream matches
//the transmitted portion of the accumulated syndrome.
//The number of residual bit errors is also calculated.
void decodeBits(double *LLR_intrinsic, double *accumulatedSyndrome, double *source, char *ladderFile,
                double *decoded, double *rate, double *numErrors)
{
    FILE *fp;
    int n, m, nzmax, *ir, *jc;
    int numCodes, totalNumInc, numInc, *txSeq;
    int code, k, currIndex, prevIndex;
    double *syndrome;
    
    fp = fopen(ladderFile, "r");
 
    fscanf(fp, "%d", &numCodes);
    fscanf(fp, "%d", &n);
    fscanf(fp, "%d", &nzmax);
    fscanf(fp, "%d", &totalNumInc);
        
    ir = mxCalloc(nzmax, sizeof(int));
    jc = mxCalloc(n+1, sizeof(int));
    txSeq = mxCalloc(totalNumInc, sizeof(int)); //actual length: numInc
    syndrome = mxCalloc(n, sizeof(double)); //actual length: m
    
    for(k=0; k<n+1; k++)
        fscanf(fp, "%d", jc+k);    
    
    //iterate through codes of increasing rate
    for(code=0; code<numCodes; code++)
    {
        fscanf(fp, "%d", &numInc);
        for(k=0; k<numInc; k++)
            fscanf(fp, "%d", txSeq+k);
        for(k=0; k<nzmax; k++)
            fscanf(fp, "%d", ir+k);
        m = (n/totalNumInc)*numInc;
        
        rate[0] = ((double) m)/((double) n);

        if(rate[0]==1)
        {
            fclose(fp);
            for(k=0; k<n; k++)
                decoded[k]=source[k]; //result of Gaussian elimination
            numErrors[0] = 0;
            return;
        }
        
        currIndex = txSeq[0];
        syndrome[0] = accumulatedSyndrome[currIndex];
        for(k=1; k<m; k++)
        {
            prevIndex = currIndex;
            currIndex = txSeq[k%numInc] + (k/numInc)*totalNumInc;
            syndrome[k] = (double) (((int) (accumulatedSyndrome[currIndex] + accumulatedSyndrome[prevIndex])) % 2);
        }

        if(beliefPropagation(ir, jc, m, n, nzmax, LLR_intrinsic, syndrome, decoded))
        {
            fclose(fp);
            numErrors[0] = 0;
            for(k=0; k<n; k++)
                numErrors[0] += (double) (decoded[k]!=source[k]);
            return;
        }   
    }
}

//For implementation outline of beliefPropagation(), refer to 
//W. E. Ryan, "An Introduction to LDPC Codes," in CRC Handbook for Coding 
//and Signal Processing for Recording Systems (B. Vasic, ed.) CRC Press, 2004.
//available online (as of May 8, 2006) at 
//http://www.ece.arizona.edu/~ryan/New%20Folder/ryan-crc-ldpc-chap.pdf

//beliefPropagation() runs several iterations belief propagation until
//either the decoded bitstream agrees with the transmitted portion of 
//accumulated syndrome or convergence or the max number of iterations.
//Returns 1 if decoded bitstream agrees with 
//transmitted portion of accumulated syndrome.
int beliefPropagation(int *ir, int *jc, int m, int n, int nzmax, 
                       double *LLR_intrinsic, double *syndrome,
                       double *decoded)
{
    int iteration, k, l, sameCount;
    double *LLR_extrinsic, *check_LLR, *check_LLR_mag, *rowTotal, *LLR_overall;
    
    LLR_extrinsic = mxCalloc(nzmax, sizeof(double));
    check_LLR = mxCalloc(nzmax, sizeof(double));
    check_LLR_mag = mxCalloc(nzmax, sizeof(double));
    rowTotal = mxCalloc(m, sizeof(double));    
    LLR_overall = mxCalloc(n, sizeof(double));
    
    sameCount = 0;
    for(k=0; k<n; k++)
        decoded[k] = 0;
    
    //initialize variable-to-check messages
    for(k=0; k<n; k++)
        for(l=jc[k]; l<jc[k+1]; l++)
            LLR_extrinsic[l] = LLR_intrinsic[k];
    
    for(iteration=0; iteration<100; iteration++)
    {
        //Step 1: compute check-to-variable messages
        
        for(k=0; k<nzmax; k++)
        {
            check_LLR[k] = (double) ((LLR_extrinsic[k]<0) ? -1 : 1);
            check_LLR_mag[k] = ((LLR_extrinsic[k]<0) ? -LLR_extrinsic[k] : LLR_extrinsic[k]);
        }
        
        for(k=0; k<m; k++)
            rowTotal[k] = (double) ((syndrome[k]==1) ? -1 : 1);
        for(k=0; k<nzmax; k++)
            rowTotal[ir[k]] *= check_LLR[k];        
        for(k=0; k<nzmax; k++)
            check_LLR[k] = check_LLR[k] * rowTotal[ir[k]];
            //sign of check-to-variable messages
        
        for(k=0; k<nzmax; k++)
            check_LLR_mag[k] = -log( tanh( max(check_LLR_mag[k], 0.000000001)/2 ) );
        for(k=0; k<m; k++)
            rowTotal[k] = (double) 0;
        for(k=0; k<nzmax; k++)
            rowTotal[ir[k]] += check_LLR_mag[k];        
        for(k=0; k<nzmax; k++)
            check_LLR_mag[k] = -log( tanh( max(rowTotal[ir[k]] - check_LLR_mag[k], 0.000000001)/2 ) );
            //magnitude of check-to-variable messages
            
        for(k=0; k<nzmax; k++)
            check_LLR[k] = check_LLR[k] * check_LLR_mag[k];
            //check-to-variable messages
            
        //Step 2: compute variable-to-check messages
        
        for(k=0; k<n; k++)
        {
            LLR_overall[k] = LLR_intrinsic[k];
            for(l=jc[k]; l<jc[k+1]; l++)
                LLR_overall[k] += check_LLR[l];
        }
            
        for(k=0; k<n; k++)
            for(l=jc[k]; l<jc[k+1]; l++)
                LLR_extrinsic[l] = LLR_overall[k] - check_LLR[l];
                //variable-to-check messages
            
        //Step 3: test convergence and syndrome condition
        
        l = 0;
        for(k=0; k<n; k++)
            if(decoded[k] == ((LLR_overall[k]<0) ? 1 : 0))
                l++;
            else
                decoded[k] = ((LLR_overall[k]<0) ? 1 : 0);
        
        sameCount = ((l==n) ? sameCount+1 : 0); 
        
        if(sameCount==5)
            return 0; //convergence (to wrong answer)
        
        for(k=0; k<m; k++)
            rowTotal[k] = syndrome[k];
        for(k=0; k<n; k++)
            for(l=jc[k]; l<jc[k+1]; l++)
                rowTotal[ir[l]] += decoded[k];
                
        for(k=0; k<m; k++)
            if(((int) rowTotal[k] % 2) != 0)
                break;
            else if(k==m-1)
                return 1; //all syndrome checks satisfied
           
    }
    
    return 0;
}