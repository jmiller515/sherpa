#!/usr/bin/env bash -e

if [ "`uname -s`" == "Darwin" ] ; then
    export DISPLAY=":99"
    export PATH="${PATH}:/opt/X11/bin"
    # Run headless Xvfb
    sudo Xvfb :99 -ac -screen 0 1024x768x8 &
    if [ $? != 0 ] ; then
        exit 1
    fi
fi

# Build smoke test switches, to ensure requested dependencies are reachable
if [ -n "${XSPECVER}" ]; then XSPECTEST="-x -d"; fi
if [ -n "${FITS}" ] ; then FITSTEST="-f ${FITS}"; fi
smokevars="${XSPECTEST} ${FITSTEST} -v 3"

if [ ${TEST} == submodule ]; then
    conda install -yq pytest-cov;

    python setup.py -q test -a "--cov sherpa --cov-report xml" || exit 1;
fi

# Run smoke test
cd /home
sherpa_smoke ${smokevars} || exit 1

# Run regression tests using sherpa_test
if [ ${TEST} == package ] || [ ${TEST} == none ]; then
    cd $HOME;
    conda install -yq pytest-cov;
    
    # This automatically picks up the sherpatest module when TEST==package
    sherpa_test --cov sherpa --cov-report xml || exit 1;
fi

# End
