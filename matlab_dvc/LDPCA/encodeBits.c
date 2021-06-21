//Author:  David Varodayan (varodayan@stanford.edu)
//Date:    May 8, 2006

#include <stdio.h>
#include "mex.h"

//C-MEX wrapper
void mexFunction(int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[])
{
    double *source, *accumulatedSyndrome;
    char ladderFile[50];
        
    FILE *fp;
    int n;
    
    source = mxGetPr(prhs[0]);
    mxGetString(prhs[1], ladderFile, 50);    
    
    fp = fopen(ladderFile, "r"); 
    fscanf(fp, "%d", &n);
    fscanf(fp, "%d", &n);
    fclose(fp);
       
    plhs[0] = mxCreateDoubleMatrix(1, n, mxREAL);
    accumulatedSyndrome = mxGetPr(plhs[0]);
    
    encodeBits(source, ladderFile, accumulatedSyndrome);
}

//returns entire accumulated syndrome of source wrt code of source rate 1
void encodeBits(double *source, char *ladderFile, double *accumulatedSyndrome)
{
    FILE *fp;
    int n, m, nzmax, *ir, *jc;
    int numCodes, totalNumInc, numInc, *txSeq;
    int k, l;
    
    fp = fopen(ladderFile, "r");
 
    fscanf(fp, "%d", &numCodes);
    fscanf(fp, "%d", &n);
    fscanf(fp, "%d", &nzmax);
    fscanf(fp, "%d", &totalNumInc);
        
    ir = mxCalloc(nzmax, sizeof(int));
    jc = mxCalloc(n+1, sizeof(int));
    txSeq = mxCalloc(totalNumInc, sizeof(int));
    
    for(k=0; k<n+1; k++)
        fscanf(fp, "%d", jc+k);    
    for(k=0; k<numCodes; k++)
    {
        fscanf(fp, "%d", &numInc);
        for(l=0; l<numInc; l++)
            fscanf(fp, "%d", txSeq+l);
        for(l=0; l<nzmax; l++)
            fscanf(fp, "%d", ir+l);
    }
    m = (n/totalNumInc)*numInc;
    
    fclose(fp);
    
    
    for(k=0; k<m; k++)
        accumulatedSyndrome[k] = (double) 0;
    
    //source*H'
    for(k=0; k<n; k++)
        for(l=jc[k]; l<jc[k+1]; l++)
            accumulatedSyndrome[ir[l]] += source[k];
    
    //accumulate
    for(k=1; k<m; k++)
        accumulatedSyndrome[k] += accumulatedSyndrome[k-1];
    
    //mod 2
    for(k=0; k<m; k++)
        accumulatedSyndrome[k] = (double) ((int) accumulatedSyndrome[k] % 2);
}