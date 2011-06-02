/* ----------------------------------------------------------------------------
 * This file was automatically generated by SWIG (http://www.swig.org).
 * Version 2.0.2
 *
 * Do not make changes to this file unless you know what you are doing--modify
 * the SWIG interface file instead.
 * ----------------------------------------------------------------------------- */

namespace org.doubango.tinyWRAP {

using System;
using System.Runtime.InteropServices;

public class SafeObject : IDisposable {
  private HandleRef swigCPtr;
  protected bool swigCMemOwn;

  internal SafeObject(IntPtr cPtr, bool cMemoryOwn) {
    swigCMemOwn = cMemoryOwn;
    swigCPtr = new HandleRef(this, cPtr);
  }

  internal static HandleRef getCPtr(SafeObject obj) {
    return (obj == null) ? new HandleRef(null, IntPtr.Zero) : obj.swigCPtr;
  }

  ~SafeObject() {
    Dispose();
  }

  public virtual void Dispose() {
    lock(this) {
      if (swigCPtr.Handle != IntPtr.Zero) {
        if (swigCMemOwn) {
          swigCMemOwn = false;
          tinyWRAPPINVOKE.delete_SafeObject(swigCPtr);
        }
        swigCPtr = new HandleRef(null, IntPtr.Zero);
      }
      GC.SuppressFinalize(this);
    }
  }

  public SafeObject() : this(tinyWRAPPINVOKE.new_SafeObject(), true) {
  }

  public int Lock() {
    int ret = tinyWRAPPINVOKE.SafeObject_Lock(swigCPtr);
    return ret;
  }

  public int UnLock() {
    int ret = tinyWRAPPINVOKE.SafeObject_UnLock(swigCPtr);
    return ret;
  }

}

}
