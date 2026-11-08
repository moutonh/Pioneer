//+------------------------------------------------------------------+
//|                                            AdvancedDebugger.mqh |
//|                          Advanced Debugging and Error Handling  |
//|                                 System for Large MQL4 Projects |
//+------------------------------------------------------------------+

#property strict
#include "FG_Global_Variables.mqh"
// Debug levels
enum ENUM_DEBUG_LEVEL
{
    DEBUG_NONE = 0,      // No debugging
    DEBUG_ERROR = 1,     // Only errors
    DEBUG_WARNING = 2,   // Errors and warnings
    DEBUG_INFO = 3,      // Errors, warnings, and info
    DEBUG_VERBOSE = 4    // Everything including verbose details
};

// Global debug settings
input ENUM_DEBUG_LEVEL InpDebugLevel = DEBUG_ERROR;        // Debug level
input bool InpDebugToFile = true;                          // Write debug to file
input bool InpDebugToExpertTab = false;                    // Also write to Expert tab
input string InpDebugFileName = "EA_Debug_Log.csv";        // Debug log filename
input int InpMaxDebugFileSize = 5000;                      // Max lines in debug file before rotation

// Global variables for debugging system
static datetime g_lastDebugTime = 0;
static int g_debugLineCount = 0;
static bool g_debugInitialized = false;
#define CHECK_ARRAY_INDEX(array, index) CheckArrayIndex(array, #array, __FUNCTION__, __LINE__, index)
//+------------------------------------------------------------------+
//| Initialize the debugging system                                  |
//+------------------------------------------------------------------+
bool InitializeDebugger()
{
    if(g_debugInitialized) return true;
    
    if(InpDebugToFile)
    {
        // Create debug file with header
        int handle = FileOpen(InpDebugFileName, FILE_WRITE|FILE_CSV);
        if(handle != INVALID_HANDLE)
        {
            string header = "Timestamp,Level,Function,Line,Symbol,Timeframe,Message,ArrayName,ArraySize,Index,Value,ErrorCode";
            FileWrite(handle, header);
            FileClose(handle);
            g_debugInitialized = true;
            return true;
        }
        else
        {
            Print("ERROR: Could not initialize debug file: ", InpDebugFileName);
            return false;
        }
    }
    
    g_debugInitialized = true;
    return true;
}

//+------------------------------------------------------------------+
//| Core debug logging function                                      |
//+------------------------------------------------------------------+
void WriteDebugLog(ENUM_DEBUG_LEVEL level, string functionName, int lineNumber, string message, 
                   string arrayName = "", int arraySize = -1, int index = -1, double value = 0, int errorCode = 0)
{
    if(!g_debugInitialized) InitializeDebugger();
    if(level > InpDebugLevel) return;
    
    string levelStr = "";
    switch(level)
    {
        case DEBUG_ERROR:   levelStr = "ERROR"; break;
        case DEBUG_WARNING: levelStr = "WARNING"; break;
        case DEBUG_INFO:    levelStr = "INFO"; break;
        case DEBUG_VERBOSE: levelStr = "VERBOSE"; break;
        default:           levelStr = "UNKNOWN"; break;
    }
    
    datetime currentTime = TimeCurrent();
    string timestamp = TimeToString(currentTime, TIME_DATE|TIME_MINUTES|TIME_SECONDS);
    
    // Format the debug message
    string debugLine = timestamp + "," + 
                      levelStr + "," + 
                      functionName + "," + 
                      IntegerToString(lineNumber) + "," + 
                      Symbol() + "," + 
                      IntegerToString(Period()) + "," + 
                      "\"" + message + "\"" + "," + 
                      arrayName + "," + 
                      IntegerToString(arraySize) + "," + 
                      IntegerToString(index) + "," + 
                      DoubleToString(value, 5) + "," + 
                      IntegerToString(errorCode);
    
    // Write to file
    if(InpDebugToFile)
    {
        // Check if we need to rotate the log file
        if(g_debugLineCount > InpMaxDebugFileSize)
        {
            RotateDebugFile();
        }
        
        int handle = FileOpen(InpDebugFileName, FILE_WRITE|FILE_CSV|FILE_READ);
        if(handle != INVALID_HANDLE)
        {
            // Read existing content
            string existingData = "";
            while(!FileIsEnding(handle))
            {
                existingData += FileReadString(handle) + "\n";
            }
            FileClose(handle);
            
            // Write all data back
            handle = FileOpen(InpDebugFileName, FILE_WRITE|FILE_TXT);
            if(handle != INVALID_HANDLE)
            {
                if(StringLen(existingData) > 0)
                {
                    FileWriteString(handle, existingData);
                }
                FileWriteString(handle, debugLine + "\n");
                FileClose(handle);
                g_debugLineCount++;
            }
        }
    }
    
    // Also write to Expert tab if enabled
    if(InpDebugToExpertTab)
    {
        Print("[", levelStr, "] ", functionName, ":", lineNumber, " - ", message);
        if(arrayName != "" && arraySize >= 0)
        {
            Print("   Array: ", arrayName, ", Size: ", arraySize, ", Index: ", index, ", Value: ", value);
        }
    }
}

//+------------------------------------------------------------------+
//| Rotate debug file when it gets too large                        |
//+------------------------------------------------------------------+
void RotateDebugFile()
{
    string backupName = StringSubstr(InpDebugFileName, 0, StringLen(InpDebugFileName) - 4) + "_backup.csv";
    
    // Read current file
    int currentHandle = FileOpen(InpDebugFileName, FILE_READ|FILE_TXT);
    string content = "";
    if(currentHandle != INVALID_HANDLE)
    {
        while(!FileIsEnding(currentHandle))
        {
            content += FileReadString(currentHandle) + "\n";
        }
        FileClose(currentHandle);
        
        // Write to backup
        int backupHandle = FileOpen(backupName, FILE_WRITE|FILE_TXT);
        if(backupHandle != INVALID_HANDLE)
        {
            FileWriteString(backupHandle, content);
            FileClose(backupHandle);
        }
    }
    
    // Reset main file with header
    int newHandle = FileOpen(InpDebugFileName, FILE_WRITE|FILE_TXT);
    if(newHandle != INVALID_HANDLE)
    {
        string header = "Timestamp,Level,Function,Line,Symbol,Timeframe,Message,ArrayName,ArraySize,Index,Value,ErrorCode\n";
        FileWriteString(newHandle, header);
        FileClose(newHandle);
    }
    
    g_debugLineCount = 1; // Reset counter (header = 1 line)
}

//+------------------------------------------------------------------+
//| Custom error codes for compatibility                             |
//+------------------------------------------------------------------+
#ifndef ERR_INVALID_FUNCTION_PARAMETER
#define ERR_INVALID_FUNCTION_PARAMETER 4051  // Custom error code for invalid parameter
#endif

#ifndef ERR_ARRAY_INDEX_OUT_OF_RANGE
#define ERR_ARRAY_INDEX_OUT_OF_RANGE 4052    // Custom error code for array bounds
#endif

////+------------------------------------------------------------------+
////| Safe array access with automatic debugging                       |
////+------------------------------------------------------------------+
//double SafeArrayAccess(double &array[], int index, string arrayName, string functionName, int lineNumber, double defaultValue = 0.0)
//{
//    int arraySize = ArraySize(array);
//    
//    // Log array access attempt
//    if(InpDebugLevel >= DEBUG_VERBOSE)
//    {
//        WriteDebugLog(DEBUG_VERBOSE, functionName, lineNumber, 
//                     "Attempting array access", arrayName, arraySize, index, 0, 0);
//    }
//    
//    // Check for array bounds
//    if(arraySize == 0)
//    {
//        WriteDebugLog(DEBUG_ERROR, functionName, lineNumber, 
//                     "Array is empty/uninitialized", arrayName, arraySize, index, defaultValue, GetLastError());
//        return defaultValue;
//    }
//    
//    if(index < 0)
//    {
//        WriteDebugLog(DEBUG_ERROR, functionName, lineNumber, 
//                     "Negative array index", arrayName, arraySize, index, defaultValue, ERR_INVALID_FUNCTION_PARAMETER);
//        return defaultValue;
//    }
//    
//    if(index >= arraySize)
//    {
//        WriteDebugLog(DEBUG_ERROR, functionName, lineNumber, 
//                     "Array index out of bounds", arrayName, arraySize, index, defaultValue, ERR_ARRAY_INDEX_OUT_OF_RANGE);
//        return defaultValue;
//    }
//    
//    // Safe access
//    double value = array[index];
//    
//    if(InpDebugLevel >= DEBUG_VERBOSE)
//    {
//        WriteDebugLog(DEBUG_VERBOSE, functionName, lineNumber, 
//                     "Array access successful", arrayName, arraySize, index, value, 0);
//    }
//    
//    return value;
//}


//+------------------------------------------------------------------+
//| Custom error codes for compatibility                             |
//+------------------------------------------------------------------+
#ifndef ERR_INVALID_FUNCTION_PARAMETER
#define ERR_INVALID_FUNCTION_PARAMETER 4051  // Custom error code for invalid parameter
#endif

#ifndef ERR_ARRAY_INDEX_OUT_OF_RANGE
#define ERR_ARRAY_INDEX_OUT_OF_RANGE 4052    // Custom error code for array bounds
#endif

////+------------------------------------------------------------------+
////| Safe array access with automatic debugging                       |
////+------------------------------------------------------------------+
//double SafeArrayAccess(double &array[], int index, string arrayName, string functionName, int lineNumber, double defaultValue = 0.0)
//{
//    int arraySize = ArraySize(array);
//    
//    // Log array access attempt
//    if(InpDebugLevel >= DEBUG_VERBOSE)
//    {
//        WriteDebugLog(DEBUG_VERBOSE, functionName, lineNumber, 
//                     "Attempting array access", arrayName, arraySize, index, 0, 0);
//    }
//    
//    // Check for array bounds
//    if(arraySize == 0)
//    {
//        WriteDebugLog(DEBUG_ERROR, functionName, lineNumber, 
//                     "Array is empty/uninitialized", arrayName, arraySize, index, defaultValue, GetLastError());
//        return defaultValue;
//    }
//    
//    if(index < 0)
//    {
//        WriteDebugLog(DEBUG_ERROR, functionName, lineNumber, 
//                     "Negative array index", arrayName, arraySize, index, defaultValue, -1);
//        return defaultValue;
//    }
//    
//    if(index >= arraySize)
//    {
//        WriteDebugLog(DEBUG_ERROR, functionName, lineNumber, 
//                     "Array index out of bounds", arrayName, arraySize, index, defaultValue, -2);
//        return defaultValue;
//    }
//    
//    // Safe access
//    double value = array[index];
//    
//    if(InpDebugLevel >= DEBUG_VERBOSE)
//    {
//        WriteDebugLog(DEBUG_VERBOSE, functionName, lineNumber, 
//                     "Array access successful", arrayName, arraySize, index, value, 0);
//    }
//    
//    return value;
//}
//+------------------------------------------------------------------+
//| Safe array access with automatic debugging                       |
//+------------------------------------------------------------------+
double SafeArrayAccess(double &array[], int index, string arrayName, string functionName, int lineNumber, double defaultValue = 0.0)
{
    // First check if array pointer is valid (additional safety)
    if(ArraySize(array) < 0)
    {
        Print("CRITICAL ERROR: Invalid array pointer in ", functionName, " at line ", lineNumber);
        return defaultValue;
    }
    
    int arraySize = ArraySize(array);
    
    // Enhanced logging with null checks
    if(InpDebugLevel >= DEBUG_VERBOSE && arrayName != "" && functionName != "")
    {
        Print("DEBUG: Attempting array access - Array: ", arrayName, ", Size: ", arraySize, ", Index: ", index);
    }
    
    // Check for array bounds
    if(arraySize <= 0)
    {
        if(functionName != "" && arrayName != "")
        {
            Print("ERROR: Array is empty/uninitialized - ", arrayName, " in ", functionName, " at line ", lineNumber);
        }
        return defaultValue;
    }
    
    if(index < 0)
    {
        if(functionName != "" && arrayName != "")
        {
            Print("ERROR: Negative array index - Array: ", arrayName, ", Index: ", index, " in ", functionName);
        }
        return defaultValue;
    }
    
    if(index >= arraySize)
    {
        if(functionName != "" && arrayName != "")
        {
            Print("ERROR: Array index out of bounds - Array: ", arrayName, ", Size: ", arraySize, ", Index: ", index, " in ", functionName);
        }
        return defaultValue;
    }
    
    // Safe access with error handling
    double value = 0.0;
    
    // Use a more defensive approach
    if(index >= 0 && index < arraySize && arraySize > 0)
    {
        value = array[index];
        
        // Check if value is valid (not NaN or infinite)
        if(MathIsValidNumber(value))
        {
            if(InpDebugLevel >= DEBUG_VERBOSE && functionName != "")
            {
                Print("DEBUG: Array access successful - Value: ", value);
            }
            return value;
        }
        else
        {
            if(functionName != "" && arrayName != "")
            {
                Print("WARNING: Invalid number retrieved from array ", arrayName, " at index ", index);
            }
            return defaultValue;
        }
    }
    
    return defaultValue;
}
//+------------------------------------------------------------------+
//| Check array integrity and report issues                          |
//+------------------------------------------------------------------+
bool CheckArrayIntegrity(double &array[], string arrayName, string functionName, int lineNumber, int expectedMinSize = 0)
{
    int arraySize = ArraySize(array);
    bool hasIssues = false;
    
    // Check if array exists/is initialized
    if(arraySize == 0)
    {
        WriteDebugLog(DEBUG_WARNING, functionName, lineNumber, 
                     "Array is empty or uninitialized", arrayName, arraySize, -1, 0, 0);
        hasIssues = true;
    }
    
    // Check minimum size requirement
    if(expectedMinSize > 0 && arraySize < expectedMinSize)
    {
        WriteDebugLog(DEBUG_WARNING, functionName, lineNumber, 
                     "Array smaller than expected minimum size (expected: " + IntegerToString(expectedMinSize) + ")", 
                     arrayName, arraySize, -1, 0, 0);
        hasIssues = true;
    }
    
    // Check for invalid values (optional)
    if(arraySize > 0 && InpDebugLevel >= DEBUG_INFO)
    {
        int invalidCount = 0;
        for(int i = 0; i < MathMin(arraySize, 10); i++) // Check first 10 elements
        {
            if(array[i] != array[i]) // NaN check
            {
                invalidCount++;
            }
        }
        
        if(invalidCount > 0)
        {
            WriteDebugLog(DEBUG_WARNING, functionName, lineNumber, 
                         "Found " + IntegerToString(invalidCount) + " invalid values (NaN) in first 10 elements", 
                         arrayName, arraySize, -1, 0, 0);
            hasIssues = true;
        }
    }
    
    if(!hasIssues && InpDebugLevel >= DEBUG_INFO)
    {
        WriteDebugLog(DEBUG_INFO, functionName, lineNumber, 
                     "Array integrity check passed", arrayName, arraySize, -1, 0, 0);
    }
    
    return !hasIssues;
}
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

bool CheckArrayIndex(double &array[], string arrayName, string functionName, int lineNumber, int index)
{
    int arraySize = ArraySize(array);
    
    if(index < 0 || index >= arraySize)
    {
        WriteDebugLog(DEBUG_ERROR, functionName, lineNumber, 
                     "Array index out of bounds! Index: " + IntegerToString(index) + 
                     ", Array size: " + IntegerToString(arraySize), 
                     arrayName, arraySize, index, 0, 0);
                     Print("##### Log printed");
        return false;
    }
    
    return true;
}
//+------------------------------------------------------------------+
//| Memory usage tracker for arrays                                  |
//+------------------------------------------------------------------+
void LogMemoryUsage(string functionName, int lineNumber)
{
    if(InpDebugLevel >= DEBUG_INFO)
    {
        long memoryUsed = TerminalInfoInteger(TERMINAL_MEMORY_USED);
        WriteDebugLog(DEBUG_INFO, functionName, lineNumber, 
                     "Memory usage: " + IntegerToString(memoryUsed) + " KB", "", -1, -1, 0, 0);
    }
}

//+------------------------------------------------------------------+
//| Convenient macros for easy usage                                 |
//+------------------------------------------------------------------+
#define DEBUG_ERROR_LOG(message) WriteDebugLog(DEBUG_ERROR, __FUNCTION__, __LINE__, message)
#define DEBUG_WARNING_LOG(message) WriteDebugLog(DEBUG_WARNING, __FUNCTION__, __LINE__, message)
#define DEBUG_INFO_LOG(message) WriteDebugLog(DEBUG_INFO, __FUNCTION__, __LINE__, message)
#define DEBUG_VERBOSE_LOG(message) WriteDebugLog(DEBUG_VERBOSE, __FUNCTION__, __LINE__, message)

#define SAFE_ARRAY_GET(array, index, default) SafeArrayAccess(array, index, #array, __FUNCTION__, __LINE__, default)
#define SAFE_ARRAY_SET(array, index, value) SafeArrayAssign(array, index, value, #array, __FUNCTION__, __LINE__)
#define CHECK_ARRAY(array, minSize) CheckArrayIntegrity(array, #array, __FUNCTION__, __LINE__, minSize)

//+------------------------------------------------------------------+
//| Function execution time tracker                                  |
//+------------------------------------------------------------------+
class CExecutionTimer
{
private:
    string m_functionName;
    int m_lineNumber;
    datetime m_startTime;
    
public:
    CExecutionTimer(string functionName, int lineNumber)
    {
        m_functionName = functionName;
        m_lineNumber = lineNumber;
        m_startTime = GetTickCount();
        
        if(InpDebugLevel >= DEBUG_VERBOSE)
        {
            WriteDebugLog(DEBUG_VERBOSE, m_functionName, m_lineNumber, "Function execution started", "", -1, -1, 0, 0);
        }
    }
    
    ~CExecutionTimer()
    {
        if(InpDebugLevel >= DEBUG_INFO)
        {
            long executionTime = GetTickCount() - m_startTime;
            WriteDebugLog(DEBUG_INFO, m_functionName, m_lineNumber, 
                         "Function execution completed in " + IntegerToString(executionTime) + "ms", "", -1, -1, 0, 0);
        }
    }
};

#define TIME_FUNCTION() CExecutionTimer timer(__FUNCTION__, __LINE__)

//+------------------------------------------------------------------+
//| Updated LogSignal function using the debug system                |
//+------------------------------------------------------------------+
//int LogSignalWithDebug(string orderType)
//{
//    TIME_FUNCTION(); // Automatically track execution time
//    
//    DEBUG_INFO_LOG("Starting signal logging for order type: " + orderType);
//    
//    double myArrayValues[100];
//    ArrayInitialize(myArrayValues, 0);
//    
//    int j = 1;
//    
//    // Check all arrays before accessing them
//    CHECK_ARRAY(MT_Wavecount, 1);
//    CHECK_ARRAY(PriceActionBar, 1);
//    CHECK_ARRAY(ST_Stoc_Divergence, 1);
//    
//    // Use safe array access for all assignments
//    myArrayValues[0] = DoubleToStr(SAFE_ARRAY_GET(MT_Wavecount, j, 0),1);
//    myArrayValues[1] = DoubleToStr(SAFE_ARRAY_GET(Momentum_Divergence_Partial, j, 0),1);
//    myArrayValues[2] = DoubleToStr(SAFE_ARRAY_GET(Momentum_Divergence_Full, j, 0),1);
//    myArrayValues[3] = DoubleToStr(SAFE_ARRAY_GET(ST_ReloadPattern, j, 0),1);
//    myArrayValues[4] = DoubleToStr(SAFE_ARRAY_GET(MT_ReloadPattern, j, 0),1);
//    myArrayValues[5] = DoubleToStr(SAFE_ARRAY_GET(FirstCycleAfter_X, j, 0),1);
//    myArrayValues[6] = DoubleToStr(SAFE_ARRAY_GET(FirstCycleAfter_DADturns, j, 0),1);
//    myArrayValues[7] = DoubleToStr(SAFE_ARRAY_GET(MT_MOM_Wave3, j, 0),1);
//    myArrayValues[8] = DoubleToStr(SAFE_ARRAY_GET(MT_MOM_Wave2, j, 0),1);
//    myArrayValues[9] = DoubleToStr(SAFE_ARRAY_GET(X_Marks_the_spot, j, 0),1);
//    myArrayValues[10] = DoubleToStr(SAFE_ARRAY_GET(ImpulseWithoutRetrace, j, 0),1);
//    myArrayValues[11] = DoubleToStr(SAFE_ARRAY_GET(MT_Rubberband, j, 0),1);
//    myArrayValues[12] = DoubleToStr(SAFE_ARRAY_GET(ST_Rubberband, j, 0),1);
//    myArrayValues[13] = DoubleToStr(SAFE_ARRAY_GET(LT_Conservative, j, 0),1);
//    
//    // Skip 14-30 (already initialized to 0)
//    
//    myArrayValues[31] = DoubleToStr(SAFE_ARRAY_GET(MT_D_Angle, j, 0),1);
//    myArrayValues[32] = DoubleToStr(SAFE_ARRAY_GET(MT_K_Angle, j, 0),1);
//    myArrayValues[33] = DoubleToStr(SAFE_ARRAY_GET(MT_MOM_Angle, j, 0),1);
//    myArrayValues[34] = DoubleToStr(SAFE_ARRAY_GET(ST_D_Angle, j, 0),1);
//    myArrayValues[35] = DoubleToStr(SAFE_ARRAY_GET(ST_K_Angle, j, 0),1);
//    myArrayValues[36] = DoubleToStr(SAFE_ARRAY_GET(ST_MOM_Angle, j, 0),1);
//    
//    // Skip 37-50 (already initialized to 0)
//    
//    myArrayValues[51] = DoubleToStr(SAFE_ARRAY_GET(PriceActionBar, j, 0),1);          // Now safe!
//    myArrayValues[52] = DoubleToStr(SAFE_ARRAY_GET(ST_Stoc_Divergence, j, 0),1);      // Now safe!
//    
//    // Continue with remaining assignments...
//    myArrayValues[60] = DoubleToStr(SAFE_ARRAY_GET(TD_Countdown_EXIT, j, 0),1);
//    myArrayValues[61] = DoubleToStr(SAFE_ARRAY_GET(TD_Nine_EXIT, j, 0),1);
//    myArrayValues[62] = DoubleToStr(SAFE_ARRAY_GET(Riding21EMA_output, j, 0),1);
//    myArrayValues[63] = DoubleToStr(SAFE_ARRAY_GET(Riding8EMA_output, j, 0),1);
//    myArrayValues[64] = DoubleToStr(SAFE_ARRAY_GET(SMIdivergence, j, 0),1);
//    myArrayValues[65] = DoubleToStr(SAFE_ARRAY_GET(SMIclimax_Exit, j, 0),1);
//    myArrayValues[66] = DoubleToStr(SAFE_ARRAY_GET(RSI_BB_Stoc_EXIT, j, 0),1);
//    myArrayValues[67] = DoubleToStr(SAFE_ARRAY_GET(ADX_EXIT, j, 0),1);
//    myArrayValues[68] = DoubleToStr(SAFE_ARRAY_GET(MFI_EXIT, j, 0),1);
//    myArrayValues[69] = DoubleToStr(SAFE_ARRAY_GET(BB_RSI_EXIT, j, 0),1);
//    myArrayValues[70] = DoubleToStr(SAFE_ARRAY_GET(CCI_EXIT, j, 0),1);
//    
//    LogMemoryUsage(__FUNCTION__, __LINE__);
//    
//    bool result = LogTradingSignal(currentSymbol,currentTimeframe, orderType, 0.1, myArrayValues);
// 
//    if(result)
//    {
//        DEBUG_INFO_LOG("Signal logged successfully");
//    }
//    else
//    {
//        DEBUG_ERROR_LOG("Failed to log signal");
//    }
//    
//    return result ? 1 : 0;
//}

//+------------------------------------------------------------------+
//| Initialize the debug system in your EA's OnInit()               |
//+------------------------------------------------------------------+
/*
// Add this to your EA's OnInit():
void OnInit()
{
    InitializeDebugger();
    DEBUG_INFO_LOG("EA started successfully");
    
    // Your existing OnInit code...
}
*/
//Problem 1: Array Out of Range
//mql4// OLD (crashes):
//myArrayValues[51] = PriceActionBar[j];
//
//// NEW (safe):
//myArrayValues[51] = SAFE_ARRAY_GET(PriceActionBar, j, 0);
//Problem 2: Missing TRIGGER Data
//mql4// Add this before your WriteCustomIndicatorRowFromArray calls:
//CHECK_ARRAY(PriceActionBar, 31);
//CHECK_ARRAY(ST_Stoc_Divergence, 31);
//DEBUG_INFO_LOG("About to process TRIGGER section");
//Problem 3: Hard to Track Issues
//mql4// Add anywhere you suspect problems:
//DEBUG_ERROR_LOG("Checkpoint A reached");
//DEBUG_WARNING_LOG("Suspicious value: " + DoubleToString(someValue));
//Automatic Array Resizing:
//If you try to access beyond array bounds, it can auto-resize!
//Function Timing:
//mql4void MyFunction()
//{
//    TIME_FUNCTION(); // Automatically logs execution time
//    // Your code here...
//}

//Check array when "array out of range" errors
// 1.put this @ top of the program
//#define CHECK_ARRAY_INDEX(array, index) CheckArrayIndex(array, #array, __FUNCTION__, __LINE__, index)
 
// 2. this @ place of error
 //CHECK_ARRAY_INDEX(CandleClose, i);
 
 
 
//+------------------------------------------------------------------+
//| Function to debug all non-zero array values                       |
//| Writes array information to the Files folder                      |
//+------------------------------------------------------------------+
void DebugArrayValue(string arrayName, double &array[])
{
    int arraySize = ArraySize(array);
    string filename = arrayName + "_debug.txt";
    int fileHandle = FileOpen(filename, FILE_WRITE|FILE_TXT|FILE_ANSI);
    
    if(fileHandle != INVALID_HANDLE)
    {
        FileWrite(fileHandle, "=== Array Debug Info ===");
        FileWrite(fileHandle, "Timestamp: " + TimeToString(TimeCurrent(), TIME_DATE|TIME_SECONDS));
        FileWrite(fileHandle, "Array Name: " + arrayName);
        FileWrite(fileHandle, "Array Size: " + IntegerToString(arraySize));
        FileWrite(fileHandle, "");
        
        // Count non-zero values
        int nonZeroCount = 0;
        for(int i = 0; i < arraySize; i++)
        {
            if(array[i] != 0)
                nonZeroCount++;
        }
        
        FileWrite(fileHandle, "Non-Zero Values Found: " + IntegerToString(nonZeroCount));
        FileWrite(fileHandle, "");
        FileWrite(fileHandle, "--- All Non-Zero Values ---");
        FileWrite(fileHandle, "Index | Value");
        FileWrite(fileHandle, "------|------------------");
        
        // Write all non-zero values
        for(int i = 0; i < arraySize; i++)
        {
            if(array[i] != 0)
            {
                FileWrite(fileHandle, "[" + IntegerToString(i) + "] = " + DoubleToString(array[i], 8));
            }
        }
        
        FileWrite(fileHandle, "");
        FileWrite(fileHandle, "======================");
        FileClose(fileHandle);
        
        Print("Debug info written to: ", filename, " (", nonZeroCount, " non-zero values)");
    }
    else
    {
        Print("ERROR: Failed to open file for writing: ", filename);
    }
}

//+------------------------------------------------------------------+
//| Example usage in your code                                        |
//+------------------------------------------------------------------+
/*
void OnStart()
{
    double TD_Countdown[];
    ArrayResize(TD_Countdown, 2000);
    
    // Fill array with some test data (mix of zeros and non-zeros)
    for(int i = 0; i < ArraySize(TD_Countdown); i++)
    {
        if(i % 10 == 0)  // Every 10th element
            TD_Countdown[i] = i * 1.5;
        else
            TD_Countdown[i] = 0;
    }
    
    // Debug the entire array - will only show non-zero values
    DebugArrayValue("TD_Countdown", TD_Countdown);
}
*/