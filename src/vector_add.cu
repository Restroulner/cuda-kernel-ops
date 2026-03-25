#include <iostream>

// CUDA kernel to add two vectors
__global__ void vectorAdd(const float *A, const float *B, float *C, int numElements)
{
    int i = blockDim.x * blockIdx.x + threadIdx.x;
    if (i < numElements)
    {
        C[i] = A[i] + B[i];
    }
}

// Host code
int main()
{
    int numElements = 5;
    size_t size = numElements * sizeof(float);

    // Host input vectors
    float h_A[] = {1.0f, 2.0f, 3.0f, 4.0f, 5.0f};
    float h_B[] = {10.0f, 20.0f, 30.0f, 40.0f, 50.0f};
    float h_C[numElements];

    // Device input vectors
    float *d_A, *d_B, *d_C;

    // Allocate GPU buffers
    cudaMalloc((void**)&d_A, size);
    cudaMalloc((void**)&d_B, size);
    cudaMalloc((void**)&d_C, size);

    // Copy host vectors to device
    cudaMemcpy(d_A, h_A, size, cudaMemcpyHostToDevice);
    cudaMemcpy(d_B, h_B, size, cudaMemcpyHostToDevice);

    // Launch kernel
    int threadsPerBlock = 256;
    int blocksPerGrid = (numElements + threadsPerBlock - 1) / threadsPerBlock;
    vectorAdd<<<blocksPerGrid, threadsPerBlock>>>(d_A, d_B, d_C, numElements);

    // Copy device result back to host
    cudaMemcpy(h_C, d_C, size, cudaMemcpyDeviceToHost);

    // Verify result
    std::cout << "Vector Addition Result:" << std::endl;
    for (int i = 0; i < numElements; ++i)
    {
        std::cout << h_C[i] << " ";
    }
    std::cout << std::endl;

    // Free device memory
    cudaFree(d_A);
    cudaFree(d_B);
    cudaFree(d_C);

    return 0;
}
