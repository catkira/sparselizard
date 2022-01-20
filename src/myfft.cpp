#include "myfft.h"


std::vector<std::vector<densematrix>> myfft::fft(densematrix input, int mym, int myn)
{
    // Number of time evaluations.
    int numtimeevals = input.countrows();
    // Number of 1D transforms to perform:
    int numtransforms = input.countcolumns();

    
    ////////// Prepare the 'plan' to compute the FFT. 
    // We are computing the fft on every column (1D transforms):
    int transformdim = 1;
    // Length of every 1D transform:
    int n[] = {numtimeevals};
    // The data is in consecutive memory adresses:
    int idist = 1;
    int odist = 1;
    // Distance between two consecutive column entries:
    int istride = numtransforms;
    int ostride = numtransforms;
    // Additional inputs required by fftw:
    int* inembed = n;
    int* onembed = n;
    

    std::vector<std::vector<densematrix>> output(numtimeevals + 1, std::vector<densematrix> {});
    

    
    removeroundoffnoise(output);
    
    return output;
}

void myfft::removeroundoffnoise(std::vector<std::vector<densematrix>>& input, double threshold)
{    
    // First compute the max(abs()) of all harmonics:
    std::vector<double> maxabs(input.size(), 0);
    
    for (int harm = 1; harm < input.size(); harm++)
    {
        if (input[harm].size() > 0)
            maxabs[harm] = input[harm][0].maxabs();
    }
    
    // Compute the overall harm max:
    double harmmax = 0;
    for (int i = 1; i < input.size(); i++)
    {
        if (maxabs[i] > harmmax)
            harmmax = maxabs[i];
    }
    
    // Kill the too small harmonics:
    for (int harm = 1; harm < input.size(); harm++)
    {
        if (input[harm].size() > 0 && maxabs[harm] < threshold*harmmax)
            input[harm] = {};
    }
}

densematrix myfft::inversefft(std::vector<std::vector<densematrix>>& input, int numtimevals, int mym, int myn)
{
    // Get all times at which to evaluate:
    std::vector<double> timevals(numtimevals);
    
    double pi = 3.141592653589793238;
    double phasestep = 2.0*pi / ((double)(numtimevals));

    for(int i = 0; i < numtimevals; i++)
        timevals[i] = i*phasestep;
        
    // The end results goes here. Initial value is 0.
    densematrix output(numtimevals, mym*myn, 0);
    
    // Loop on all non zero harmonics:
    densematrix sincoseval(numtimevals,1);
    double* valvec = sincoseval.getvalues();
    
    for (int harm = 1; harm < input.size(); harm++)
    {
        if (input[harm].size() != 0)
        {
            // The current harmonic has a frequency currentfreq*f0.
            int currentfreq = harmonic::getfrequency(harm);
        
            // Evaluate the current sin or cos term for every time step:
            if (harmonic::iscosine(harm))
            {
                for (int i = 0; i < numtimevals; i++)
                    valvec[i] = std::cos(currentfreq*phasestep*i);
            }
            else
            {
                for (int i = 0; i < numtimevals; i++)
                    valvec[i] = std::sin(currentfreq*phasestep*i);
            }            
            output.add( sincoseval.multiply( input[harm][0].flatten() ) );
        }
    }
    return output;
}

densematrix myfft::toelementrowformat(densematrix timestepsinrows, int numberofelements)
{
    int numberoftimesteps = timestepsinrows.countrows();
    int numberofevaluationpoints = timestepsinrows.countcolumns()/numberofelements;
    densematrix output(numberofelements, numberoftimesteps*numberofevaluationpoints);
    
    double* in = timestepsinrows.getvalues();
    double* out = output.getvalues();
    
    for (int elem = 0; elem < numberofelements; elem++)
    {    
        for (int t = 0; t < numberoftimesteps; t++)
        {
            for (int evalpt = 0; evalpt < numberofevaluationpoints; evalpt++)
                out[elem*numberoftimesteps*numberofevaluationpoints+t*numberofevaluationpoints+evalpt] = in[t*numberofelements*numberofevaluationpoints+elem*numberofevaluationpoints+evalpt];
        }
    }
    return output;
}




