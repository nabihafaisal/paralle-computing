%%writefile sum_local.cu

#include <stdio.h>

// Kernel function to add two arrays element-wise
__global__ void add(int *a, int *b, int *c, int n) {
    // Calculate the global index of the current thread
    int i = blockDim.x * blockIdx.x + threadIdx.x;

    // Declare a local variable to hold the result of addition
    int local_result = 0;

    // Perform the addition operation for the corresponding elements
    if (i < n)
        local_result = a[i] + b[i];

    // Store the local result in the output array
    //if (i < n)
        c[i] = local_result;
}

int main() {
    int n = 10;
    int *a, *b, *c;
    int *d_a, *d_b, *d_c;
    int size = n * sizeof(int);

    // Allocate memory for arrays a, b, and c on the host
    a = (int *)malloc(size);
    b = (int *)malloc(size);
    c = (int *)malloc(size);

    // Initialize arrays a and b on the host
    for (int i = 0; i < n; i++) {
        a[i] = i;
        b[i] = i * 2;
    }

    // Allocate memory for arrays d_a, d_b, and d_c on the device
    cudaMalloc((void **)&d_a, size);
    cudaMalloc((void **)&d_b, size);
    cudaMalloc((void **)&d_c, size);

    // Copy arrays a and b from host to device
    cudaMemcpy(d_a, a, size, cudaMemcpyHostToDevice);
    cudaMemcpy(d_b, b, size, cudaMemcpyHostToDevice);

    // Launch kernel function with one thread block and n threads
    add<<<1, n>>>(d_a, d_b, d_c, n);

    // Copy array c from device to host
    cudaMemcpy(c, d_c, size, cudaMemcpyDeviceToHost);

    // Print the result
    for (int i = 0; i < n; i++)
        printf("%d + %d = %d\n", a[i], b[i], c[i]);

    // Free device memory
    cudaFree(d_a);
    cudaFree(d_b);
    cudaFree(d_c);

    // Free host memory
    free(a);
    free(b);
    free(c);

    return 0;
}
