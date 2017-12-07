package me.tkunic.kiko;

/**
 * Given two microphone streams and the distance between them, calculates the direction of the
 * sound source relative to the phone.
 */

public class LocalizeSounds {
  public static final double BASELINE = 0.147;
  public static final double SPEED_OF_SOUND = 343.0;
  public static final double PI = 3.14159265359;
  private final int maxTau;
  private final int sampleRate;

  public LocalizeSounds(int inSampleRate) {
    sampleRate = inSampleRate;

    maxTau = (int) Math.floor((BASELINE / SPEED_OF_SOUND) * sampleRate);
  }

  public LocalizationResult localizeSource(float[] left, float[] right) {
    int n = left.length;

    double[] xcl = new double[maxTau + 1];
    double[] xcr = new double[maxTau + 1];

    double lmax = 0;
    double rmax = 0;
    int lmaxIdx = 0;
    int rmaxIdx = 0;
    for (int i = 0; i < maxTau+1; ++i) {

      double xclVal = 0;
      double xcrVal = 0;
      for (int j = 0; j < n-i; ++j) {
        // calculate right.slice(i, n).innerProduct(left.slice(0, n-i))
        xclVal += right[j+i] * left[j];
        // calculate left.slice(i, n).innerProduct(right.slice(0, n-i))
        xcrVal += left[j+i] * right[j];
      }

      xcl[i] = Math.pow(xclVal, 2) / (n - i);
      xcr[i] = Math.pow(xcrVal, 2) / (n - i);

      // get max index
      if (xcl[i] > lmax) {
        lmax = xcl[i];
        lmaxIdx = i;
      }
      if (xcr[i] > rmax) {
        rmax = xcr[i];
        rmaxIdx = i;
      }
    }

    float tau;
    if (xcl[lmaxIdx] > xcr[rmaxIdx]) {
        tau = lmaxIdx;
    } else {
      tau = -rmaxIdx;
    }

    // Convert to angle
    int angle;
    if (tau >= maxTau) {
      angle = 90;
    } else if (tau <= -maxTau) {
      angle = -90;
    } else {
      angle = (int) (Math.asin(tau/maxTau) * 180/PI);
    }

    return new LocalizationResult(angle);
  }

  public class LocalizationResult {

    public final float loudestAngle;

    public LocalizationResult(int i) {
      loudestAngle = i;
    }
  }
}
