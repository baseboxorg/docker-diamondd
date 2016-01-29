
#!/bin/bash
#
# Configure broken host machine to run correctly
#
set -ex

DMD_IMAGE=${DMD_IMAGE:-baseboxorg/diamondd}

#distro=$1
#shift

#memtotal=$(grep ^MemTotal /proc/meminfo | awk '{print int($2/1024) }')

#
# Only do swap hack if needed
#
#if [ $memtotal -lt 2048 -a $(swapon -s | wc -l) -lt 2 ]; then
  #  fallocate -l 2048M /swap || dd if=/dev/zero of=/swap bs=1M count=2048
#    mkswap /swap
#    grep -q "^/swap" /etc/fstab || echo "/swap swap swap defaults 0 0" >> /etc/fstab
#    swapon -a
#fi

#free -m


# Always clean-up, but fail successfully
docker kill diamondd-data diamondd-node 2>/dev/null || true
docker rm diamondd-data diamondd-node 2>/dev/null || true
stop docker-diamondd 2>/dev/null || true

# Always pull remote images to avoid caching issues
if [ -z "${DMD_IMAGE##*/*}" ]; then
    docker pull $DMD_IMAGE
fi

# Initialize the data container
echo "starting diamondd-data container..."
docker run --name=diamondd-data -v /diamond busybox:latest chown 1000:1000 /diamond
echo "copying diamond blockchain and wallet into diamondd-data..."
docker cp ./vagrant/data/apps/diamondd/.Diamond diamondd-data:/diamond
echo "done update diamondd-data"
#docker run --volumes-from=diamondd-data --rm $DMD_IMAGE dmd_init

# Start diamondd via upstart and docker
curl https://raw.githubusercontent.com/baseboxorg/docker-diamondd/master/init/upstart.init > /etc/init/docker-diamondd.conf
start docker-diamondd

set +ex
echo "Resulting Diamond.conf:"
docker run --volumes-from=diamondd-data --rm $DMD_IMAGE cat /diamond/.Diamond/Diamond.conf
