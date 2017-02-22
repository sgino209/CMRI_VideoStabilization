function OK = IsGpuAvailable
try
    d = gpuDevice;
    OK = d.DeviceSupported;
catch %#ok<CTCH>
    OK = false;
end