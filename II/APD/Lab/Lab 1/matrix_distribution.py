from mpi4py import MPI
import numpy as np
import math


def main():
    comm = MPI.COMM_WORLD
    rank = comm.Get_rank()
    size = comm.Get_size()

    n = max(2, size)  # n >= p

    if rank == 0:
        matrix = np.random.randint(1, 10, (n, n))
        print(f"Matrice {n}x{n}:\n{matrix}")
    else:
        matrix = None

    comm.Barrier()

    # --- Linii (Scatterv) ---
    if rank == 0:
        print("\n=== PE LINII ===")
    rpp = n // size
    counts = [rpp * n] * size
    counts[size - 1] = (n - (size - 1) * rpp) * n
    displs = [0] + list(np.cumsum(counts[:-1]))

    n_local = (n - (size - 1) * rpp) if rank == size - 1 else rpp
    recv = np.empty(counts[rank], dtype=np.int64)

    if rank == 0:
        comm.Scatterv([matrix.flatten(), (counts, displs)], recv, root=0)
    else:
        comm.Scatterv([None, (counts, displs)], recv, root=0)

    local = recv.reshape(n_local, n) if rank != 0 or n_local != n else recv.reshape(n_local, n)
    msgs = comm.gather(f"Procesul {rank}: {local.shape[0]} linii\n{local}", root=0)
    if rank == 0:
        for m in msgs:
            print(m)

    # --- Coloane (Scatterv pe A.T) ---
    if rank == 0:
        print("\n=== PE COLOANE ===")
    cpp = n // size
    counts = [cpp * n] * size
    counts[size - 1] = (n - (size - 1) * cpp) * n
    displs = [0] + list(np.cumsum(counts[:-1]))

    nc_local = (n - (size - 1) * cpp) if rank == size - 1 else cpp
    recv = np.empty(counts[rank], dtype=np.int64)

    if rank == 0:
        comm.Scatterv([matrix.T.flatten(), (counts, displs)], recv, root=0)
    else:
        comm.Scatterv([None, (counts, displs)], recv, root=0)

    local = recv.reshape(nc_local, n).T
    msgs = comm.gather(f"Procesul {rank}: {local.shape[1]} coloane\n{local}", root=0)
    if rank == 0:
        for m in msgs:
            print(m)

    # --- Blocuri 2D (Scatterv) ---
    if rank == 0:
        print("\n=== PE BLOCURI ===")
    br = int(math.sqrt(size))
    bc = size // br
    if br * bc != size:
        br, bc = 1, size
    rpb = (n + br - 1) // br
    cpb = (n + bc - 1) // bc

    def block_size(r):
        i, j = r // bc, r % bc
        nr = min(rpb, n - i * rpb)
        nc = min(cpb, n - j * cpb)
        return nr * nc

    counts = [block_size(r) for r in range(size)]
    displs = [0] + list(np.cumsum(counts[:-1]))

    recv = np.empty(counts[rank], dtype=np.int64)

    if rank == 0:
        buf = np.empty(sum(counts), dtype=np.int64)
        for r in range(size):
            i, j = r // bc, r % bc
            sr, er = i * rpb, min((i + 1) * rpb, n)
            sc, ec = j * cpb, min((j + 1) * cpb, n)
            buf[displs[r]:displs[r] + counts[r]] = matrix[sr:er, sc:ec].flatten()
        comm.Scatterv([buf, (counts, displs)], recv, root=0)
    else:
        comm.Scatterv([None, (counts, displs)], recv, root=0)

    nr = min(rpb, n - (rank // bc) * rpb)
    nc = min(cpb, n - (rank % bc) * cpb)
    local = recv.reshape(nr, nc)
    msgs = comm.gather(f"Procesul {rank}: bloc {local.shape}\n{local}", root=0)
    if rank == 0:
        for m in msgs:
            print(m)


if __name__ == "__main__":
    main()
