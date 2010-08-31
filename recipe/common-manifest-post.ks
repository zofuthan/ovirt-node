%post
# Create post-image processing manifests
rpm -qa --qf '%{name}-%{version}-%{release}.%{arch} (%{SIGGPG:pgpsig})\n' | \
    sort > /manifest-rpm.txt
rpm -qa --qf '%{sourcerpm}\n' | sort -u > /manifest-srpm.txt
# collect all included licenses rhbz#601927
rpm -qa --qf '%{license}\n' | sort -u > /manifest-license.txt
# dependencies
rpm -qa | xargs -n1 rpm -e --test 2> /manifest-deps.txt
find / -print -exec rpm -qf {} \; > /manifest-owns.txt
# this one is kept in root for fake-rpm-query
rpm -qa --qf '%{NAME}\t%{VERSION}\t%{RELEASE}\t%{BUILDTIME}\n' | \
    sort > /rpm-qa.txt
# remove rpmdb rhbz#596718
rm -rf /var/lib/rpm
du -akx --exclude=/var/cache/yum / > /manifest-file.txt
du -x --exclude=/var/cache/yum / > /manifest-dir.txt
bzip2 /manifest-deps.txt /manifest-owns.txt /manifest-file.txt /manifest-dir.txt

%end

%post --nochroot
# Move manifests to ISO
mv $INSTALL_ROOT/manifest-* $LIVE_ROOT/isolinux

# only works on x86, x86_64
if [ "$(uname -i)" = "i386" -o "$(uname -i)" = "x86_64" ]; then
    if [ ! -d $LIVE_ROOT/LiveOS ]; then mkdir -p $LIVE_ROOT/LiveOS ; fi
    cp /usr/bin/livecd-iso-to-disk $LIVE_ROOT/LiveOS
    cp /usr/bin/livecd-iso-to-pxeboot $LIVE_ROOT/LiveOS
fi
%end
