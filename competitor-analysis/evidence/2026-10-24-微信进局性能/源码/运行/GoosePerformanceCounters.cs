namespace CatchGoose
{
    public static class GoosePerformanceCounters
    {
        public static double createMs, createMaxMs;
        public static void Reset() { createMs = createMaxMs = 0; }
        public static void Created(long started)
        {
            double ms=(System.Diagnostics.Stopwatch.GetTimestamp()-started)*1000.0/System.Diagnostics.Stopwatch.Frequency;
            createMs+=ms;createMaxMs=System.Math.Max(createMaxMs,ms);
        }
    }
}
